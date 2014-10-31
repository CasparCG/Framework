/*
* Copyright (c) 2011 Sveriges Television AB <info@casparcg.com>
*
* This file is part of CasparCG (www.casparcg.com).
*
* CasparCG is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* CasparCG is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with CasparCG. If not, see <http://www.gnu.org/licenses/>.
*
* Author: Helge Norberg
*/
package se.svt.caspar.amcp;

import java.io.StringReader;

import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.xml.sax.InputSource;

/**
 * TODO documentation.
 *
 * @author Helge Norberg, helge.norberg@svt.se
 */
public class XPath implements XPathContext {
    private final javax.xml.xpath.XPath mXPath;
    private final String mXml;

    /**
     * Constructor.
     *
     */
    public XPath(String xml) {
        mXPath = XPathFactory.newInstance().newXPath();
        mXml = xml;
    }

    public String getString(String expression) {
        try {
            return mXPath.evaluate(
                    expression, new InputSource(new StringReader(mXml)));
        } catch (XPathExpressionException e) {
            throw new RuntimeException(e);
        }
    }

    public int  getInt(String expression) {
        return Integer.parseInt(getString(expression));
    }

    public long getLong(String expression) {
        return Long.parseLong(getString(expression));
    }

    /** {@inheritDoc} */
    @Override
    public XPathContext getSubContext(String expression) {
        return new XPathSubContext(this, expression);
    }

    private static class XPathSubContext implements XPathContext {
        private final XPathContext mParent;
        private final String mSubExpression;

        /**
         * Constructor.
         *
         * @param parent
         */
        public XPathSubContext(XPathContext parent, String subExpression) {
            mParent = parent;
            mSubExpression = subExpression;
        }

        /** {@inheritDoc} */
        @Override
        public String getString(String expression) {
            return mParent.getString(mSubExpression + expression);
        }

        /** {@inheritDoc} */
        @Override
        public int getInt(String expression) {
            return mParent.getInt(mSubExpression + expression);
        }

        /** {@inheritDoc} */
        @Override
        public long getLong(String expression) {
            return mParent.getLong(mSubExpression + expression);
        }

        /** {@inheritDoc} */
        @Override
        public XPathContext getSubContext(String expression) {
            return new XPathSubContext(this, expression);
        }
    }
}
