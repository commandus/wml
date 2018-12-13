package com.aplpi.wapreview;

import java.lang.String;

/**
 * 
 * see http://wapreview.sourceforge.net
 *
 * Copyright (C) 2000 Robert Fuller, Applepie Solutions Ltd. 
 *                    <robert.fuller@applepiesolutions.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *

 * WmlCardInterface defines the WmlCard methods.  It exists
 * to prevent a circular dependency between WmlDeck and WmlCard.
 *
 * @author Copyright (c) 2000, Applepie Solutions Ltd.
 * @author Written by Robert Fuller &lt;robert.fuller@applepiesolutions.com&gt;
 *
 *
 * @see WmlCard
 * @see WmlDeckInterface
 */
public interface WmlCardInterface{
    public String name();
    public WmlDeckInterface deck();
    public void cardData(String S);
    public void navData(String S);
    public void onenterforward(String S);
    public void onenterbackward(String S);
    public void ontimer(String S);
    public void beginSelect(String s1, String s2, String s3, 
                            String s4, String s5, boolean b);
    public void endSelect();
    public void addOption(String s1, String s2, String s3);
}
