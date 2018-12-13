#include <stdio.h>
/**
 * This NON-LZW GIF encoding algorithm is derived from a document
 * originally published by Michael A. Mayer, currently (Aug 2000)
 * available at: http://www.danbbs.dk/~dino/whirlgif/gifcode.html
 *
 * It translates a pixelated 256-level grayscale image into a GIF image file
 *
 */
#define BLOKLEN 255
#define BUFLEN 1000

typedef struct _tn {
  int code;
  struct _tn **node;
} TreeNode,*TreePtr;

char    *AddCodeToBuffer(int code,short n,char *buf);
TreePtr InitIndices(TreePtr first,int cc);
TreePtr AddNode(int,int);
int     SearchTreeForCode(TreePtr,int *,int,int,int,int);
void    ClearTree(TreePtr,int);

pix2gif( FILE *dst, int *pixels, int cols, int rows )
{
  int     i,j,depth=8;

  TreePtr first = NULL;
  int     len,*str,*end,*target;
  int     cc,eoi,code,next;
  short   nBits;

  char    *pos,*buffer;

  char    cmd[100],filename[100];

  buffer = (char *)malloc((BUFLEN+1)*sizeof(char))+1;

  pos = buffer;

  *pos++ = 'G';
  *pos++ = 'I';
  *pos++ = 'F';
  *pos++ = '8';
  *pos++ = '7';
  *pos++ = 'a';
  
  *pos++ = 0xff & cols;
  *pos++ = (0xff00 & cols)/0x100;
  *pos++ = 0xff & rows;
  *pos++ = (0xff00 & rows)/0x100;
  *pos++ = 0xf0 | (0x7&(depth-1));
  *pos++ = 0xff;
  *pos++ = 0x0;

  for(i=0;i<256;i++) {
    *pos++ = 0xff & i;
    *pos++ = 0xff & i;
    *pos++ = 0xff & i;
  }    
  *pos++ = 0x2c;
  *pos++ = 0x00;
  *pos++ = 0x00;
  *pos++ = 0x00;
  *pos++ = 0x00;
  *pos++ = 0xff & cols;
  *pos++ = (0xff00 & cols)/0x100;
  *pos++ = 0xff & rows;
  *pos++ = (0xff00 & rows)/0x100;
  *pos++ = 0x7&(depth-1);
  *pos++ = (depth==1)?2:depth;

  fwrite(buffer,pos-buffer,1,dst);
  pos = buffer;
  buffer[0]=0x0;
  
  cc = (depth==1)?0x4:1<<depth;
  eoi = cc+1;
  next = cc+2;

  nBits = (depth==1)?3:depth+1;

  first = InitIndices(first,cc);

  pos = AddCodeToBuffer(cc,nBits,pos);

  len=1; str=pixels; end = pixels+rows*cols;
  target = str+rows*cols/10;
  while(str+len<end) {

    if(str+len>target) {
      //printf("(%3d,%3d): %3x\n",(str-pixels)/cols,(str-pixels)%cols,next);
      target += rows*cols/10;
    }

    code = SearchTreeForCode(first,str,len,next,cc,0);

    if(code!=-1) {

      pos = AddCodeToBuffer(code,nBits,pos);
      if(pos-buffer>BLOKLEN) {
        buffer[-1] = BLOKLEN;
        fwrite(buffer-1,BLOKLEN+1,1,dst);
        buffer[0]=buffer[BLOKLEN];
        buffer[1]=buffer[BLOKLEN+1];
        buffer[2]=buffer[BLOKLEN+2];
        buffer[3]=buffer[BLOKLEN+3];
        pos -= BLOKLEN;
      }
      str += len-1;
      len = 0;

      if(next==(1<<nBits)) nBits++;
      next++;

      if(next==0xfff) {
        first = InitIndices(first,cc);
        pos = AddCodeToBuffer(cc,nBits,pos);
        if(pos-buffer>BLOKLEN) {
          buffer[-1] = BLOKLEN;
          fwrite(buffer-1,BLOKLEN+1,1,dst);
          buffer[0]=buffer[BLOKLEN];
          buffer[1]=buffer[BLOKLEN+1];
          buffer[2]=buffer[BLOKLEN+2];
          buffer[3]=buffer[BLOKLEN+3];
          pos -= BLOKLEN;
        }
        next = cc+2;
        nBits = (depth==1)?3:depth+1;
      }
    }
    len++;
  }

  code = SearchTreeForCode(first,str,len,next,cc,1);
  pos = AddCodeToBuffer(code,nBits,pos);
  pos = AddCodeToBuffer(eoi,nBits,pos);
  pos = AddCodeToBuffer(0x0,-1,pos);
  buffer[-1] = pos-buffer;
  pos = AddCodeToBuffer(0x0,8,pos);
  pos = AddCodeToBuffer(0x3b,8,pos);

  fwrite(buffer-1,pos-buffer+1,1,dst);
}


TreePtr InitIndices(TreePtr first,int cc)
{
  int i;

  ClearTree(first,cc);
  
  first = AddNode(-1,cc);
  for(i=0;i<cc;i++) first->node[i] = AddNode(i,cc);

  return first;
}

TreePtr AddNode(int code,int n)
{
  TreePtr node;
  node = (TreePtr)malloc(sizeof(TreeNode));
  node->code = code;
  node->node = (TreePtr *)malloc(n*sizeof(TreePtr));

  do {
    node->node[--n] = NULL;
  } while (n);

  return node;
}

void ClearTree(TreePtr node,int n)
{
  int i;
  
  if(node==NULL) return;

  for(i=0;i<n;i++) ClearTree(node->node[i],n);
  free(node->node);
  free(node);
}

char *AddCodeToBuffer(int code,short n,char *buf)
{
  static short need = 8;
  int    mask;

  if(n<0) {
    if(need<8) {
      buf++;
      *buf = 0x0;
    }
    need = 8;
    return buf;
  }

  while(n>=need) {
    mask = (1<<need)-1;
    *buf += (mask&code)<<(8-need);
    buf++;
    *buf = 0x0;
    code = code>>need;
    n -= need;
    need = 8;
  }
  if(n) {
    mask = (1<<n)-1;
    *buf += (mask&code)<<(8-need);
    need -= n;
  }
  return buf;
}

int SearchTreeForCode(TreePtr node,int *str,int len,int next,int n,int done)
{
  if(len==0) {
    if(done) return node->code;
    return -1;
  }

  if(node->node[str[0]])
    return SearchTreeForCode(node->node[str[0]],str+1,len-1,next,n,done);
  else {
    node->node[str[0]] = AddNode(next,n);
    return node->code;
  }
}

