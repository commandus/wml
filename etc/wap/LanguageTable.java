/*======================================================================
*
*This file is part of Jwap, the Java Wap Gateway.
*Copyright (C) TietoEnator PerCom AB 
* <http://enator.se/teknik/percom/>
*
* The Jwap Project
*	David Juran & Anders Mårtensson
*      <http://simplex.hemmet.chalmers.se/Jwap.html>
*       jwap@simplex.hemmet.chalmers.se
*
*This program is free software; you can redistribute it and/or
*modify it under the terms of the GNU General Public License
*as published by the Free Software Foundation; either version 2
*of the License, or (at your option) any later version.
*
*This program is distributed in the hope that it will be useful,
*but WITHOUT ANY WARRANTY; without even the implied warranty of
*MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*GNU General Public License for more details.
*
*You should have received a copy of the GNU General Public License
*along with this program; if not, write to the Free Software
*Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA. 
*
*======================================================================*/
package COM.tietoenator.percom.WapGateway;

/** This class contains the WSP encoding of the ISO 639 Language Assiggnment..
 * The information is taken from <I>WAP WSP</I>, Appendix A, Table 41.
 * @author Anders Mårtensson
 */
final class LanguageTable extends WapTable {
    /** Contains all ISO Languages */
    private static final String[][] LANGUAGE = { {"*",null},
	{"Afar", null}, {"Abkhazian", null}, {"Afrikaans", "af"}, {"Amharic", null}, {"Arabic", null}, 
	{"Assamese", null}, {"Aymara", null}, {"Azerbaijani", null}, {"Bashkir", null}, {"Byelorussian", "be"}, 
	{"Bulgarian", "bg"}, {"Bihari", null}, {"Bislama", null}, {"Bengali", null}, {"Bangla", null}, 
	{"Tibetan", null}, {"Breton", null}, {"Catalan", "ca"}, {"Corsican", null}, {"Czech", "cs"}, 
	{"Welsh", null}, {"Danish", "da"}, {"German", "de"}, {"Bhutani", null}, {"Greek", "el"}, 
	{"English", "en"}, {"Esperanto", null}, {"Spanish", "es"}, {"Estonian", null}, {"Basque", "eu"}, 
	{"Persian", null}, {"Finnish", "fi"}, {"Fiji", null}, {"Faeroese", "fo"}, {"French", "fr"}, 
	{"Frisian", null}, {"Irish", "ga"}, {"Scots Gaelic", "gd"}, {"Galician", "gl"}, {"Guarani", null}, 
	{"Gujarati", null}, {"Hausa", null}, {"Hebrew", null}, {"Hindi", null}, {"Croatian", "hr"}, 
	{"Hungarian", "hu"}, {"Armenian", null}, {"Interlingua", null}, {"Indonesian", "id"}, {"Interlingue", null}, 
	{"Maori", null}, {"Macedonian", "mk"}, {"Malayalam", null}, {"Mongolian", null}, {"Moldavian", null}, 
	{"Marathi", null}, {"Malay", null}, {"Maltese", null}, {"Burmese", null}, {"Nauru", null}, 
	{"Nepali", null}, {"Dutch", "nl"}, {"Norwegian", "no"}, {"Occitan", null}, {"Oromo", null}, 
	{"Oriya", null}, {"Punjabi", null}, {"Polish", "po"}, {"Pashto", null}, {"Pushto", null}, 
	{"Portuguese", "pt"}, {"Quechua", null}, {"Rhaeto-Romance", null}, {"Kirundi", null}, {"Romanian", "ro"}, 
	{"Russian", "ru"}, {"Kinyarwanda", null}, {"Sanskrit", null}, {"Sindhi", null}, {"Sangho", null}, 
	{"Serbo-Croatian", null}, {"Sinhalese", null}, {"Slovak", "sk"}, {"Slovenian", "sl"}, {"Samoan", null}, 
	{"Shona", null}, {"Somali", null}, {"Albanian", "sq"}, {"Serbian", "sr"}, {"Siswati", null}, 
	{"Sesotho", null}, {"Sundanese", null}, {"Swedish", "sv"}, {"Swahili", null}, {"Tamil", null}, 
	{"Telugu", null}, {"Tajik", null}, {"Thai", null}, {"Tigtinya", null}, {"Turkmen", null}, 
	{"Inupiak", null}, {"Icelandic", "is"}, {"Italian", "it"}, {"Inuktitut", null}, {"Japanese", "ja"}, 
	{"Javanese", null}, {"Georgian", null}, {"Kazakh", null}, {"Greenlandic", null}, {"Cambodian", null}, 
	{"Kannada", null}, {"Korean", "ko"}, {"Kashmiri", null}, {"Kurdish", null}, {"Kirghiz", null}, 
	{"Latin", null}, {"Lingala", null}, {"Laothian", null}, {"Lithuanian", null}, {"Latvian", null}, 
	{"Lettish", null}, {"Malagasy", null}, {"Tagalog", null}, {"Setswana", null}, {"Tonga", null}, 
	{"Turkish", "tr"}, {"Tsonga", null}, {"Tatar", null}, {"Twi", null}, {"Uighur", null}, 
	{"Ukrainian", "uk"}, {"Urdu", null}, {"Uzbek", null}, {"Vietnamese", null}, {"Volapuk", null}, 
	{"Wolof", null}, {"Xhosa", null}, {"Yiddish", null}, {"Yoruba", null}, {"Zhuang", null}, 
	{"Chinese", "zh"}, {"Zulu", null}
    };


/** Contains all WAP codes for the ISO Languages */
    private static final byte[] LANGUAGE_CODE = { 0x00,
	0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 
	0x0b, 0x0c, 0x0d, 0x0e, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 
	0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 
	0x1e, 0x1f, 0x20, (byte)0x82, 0x22, (byte)0x83, 0x24, 0x25, 0x26, 0x27, 
	0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, (byte)0x84, 0x30, (byte)0x86, 
	0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, (byte)0x81, 
	0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x59, 
	0x5a, 0x5b, (byte)0x8c, 0x5d, 0x5e, 0x5f, 0x60, 0x61, 0x62, 0x63, 
	0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 
	0x6e, 0x6f, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 
	(byte)0x87, 0x33, 0x34, (byte)0x89, 0x36, 0x37, 0x38, 0x39, (byte)0x8a, 0x3b, 
	0x3c, 0x3d, 0x3e, 0x3f, 0x40, (byte)0x8b, 0x42, 0x43, 0x44, 0x45, 
	0x45, 0x46, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f, 
	0x50, 0x21, 0x23, 0x2f, (byte)0x85, 0x31, 0x32, (byte)0x88, 0x35, 0x3a, 
	0x41, 0x5c };
    
    /** Translates between Language and WAP code.
     * @param name ISO Language or abbevation.
     * @return Encoded WAP Content type. ERROR_CODE if error.
     */ 
    static byte getCode(String name) {
	for (int i=0; i<LANGUAGE.length; i++) {
	    /* found if (fullname-hit || abbrevation-hit) */
	    if (name.equalsIgnoreCase(LANGUAGE[i][0]) || (LANGUAGE[i][1]!=null & name.equals(LANGUAGE[i][1])) )
		return LANGUAGE_CODE[i];
	}
	// Content type not recognized
	return ERROR_CODE;
    }

    /** Translates between WAP code and ISO Language. Returns the abbrevation
     *  if there is one, otherwise the full name.
     * @param code Encoded language.
     * @return ISO Language abbrevation or name.
     * @see #getFullName(byte code)
     */ 
    static String getName(byte code) throws CodeNotInTableException {
	for (int i=0; i<LANGUAGE_CODE.length; i++) {
	    if (code==LANGUAGE_CODE[i])
		if(LANGUAGE[i][1]==null)
		    /* no abbrevation */
		    return new String(LANGUAGE[i][0]);
		else
		    return new String(LANGUAGE[i][1]);
	    
	}
	// Content type not recognized
	throw new CodeNotInTableException("Code "+code+" is not assigned to a Language.");
    }       

    /** Translates between WAP code and ISO Language. Returns the full name
     *  of the language.
     * @param code Encoded language.
     * @return ISO Language.
     * @see #getName(byte code)
     */ 
    static String getFullName(byte code) throws CodeNotInTableException {
	for (int i=0; i<LANGUAGE_CODE.length; i++) {
	    if (code==LANGUAGE_CODE[i])
		return new String(LANGUAGE[i][0]);
	}
	// Content type not recognized
	throw new CodeNotInTableException("Code "+code+" is not assigned to a Language.");
    }       


}
