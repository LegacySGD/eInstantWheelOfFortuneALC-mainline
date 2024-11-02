<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet version="1.0" exclude-result-prefixes="java" extension-element-prefixes="my-ext" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:my-ext="ext1">
<xsl:import href="HTML-CCFR.xsl"/>
<xsl:output indent="no" method="xml" omit-xml-declaration="yes"/>
<xsl:template match="/">
<xsl:apply-templates select="*"/>
<xsl:apply-templates select="/output/root[position()=last()]" mode="last"/>
<br/>
</xsl:template>
<lxslt:component prefix="my-ext" functions="formatJson retrievePrizeTable">
<lxslt:script lang="javascript">
					
					var debugFeed = [];
					var debugFlag = false;
					var colWidth = 12;
					
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
				
					function formatJson(jsonContext, translations, prizeTable, prizeValues, prizeNames)
					{
						var scenario = getScenario(jsonContext);
						var outcomeWords = getWOFOutcomeData(scenario, 0);
						var outcomePrizes = getWOFOutcomeData(scenario, 1);
						var playLetters = getPlayLetters(scenario);
						var multiplier = playLetters[playLetters.length - 1];
						var convertedPrizeValues = (prizeValues.substring(1)).split('|');
						var prizeNamesList = (prizeNames.substring(1)).split(',');
						
						registerDebugText("Words: " + outcomeWords.join());
						registerDebugText("Prize Names: " + outcomePrizes.join());
						registerDebugText("Prize Values: " + convertedPrizeValues.join());
						registerDebugText("Play Letters: " + playLetters.join());
						
						if(!isNaN(multiplier))
						{ 
							registerDebugText("Multiplier: " + multiplier);
							colWidth = playLetters.length - 1;
						}
						else
						{
							colWidth = playLetters.length;
						}

						// Output winning numbers table.
						var r = [];
						r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
						
						r.push('&lt;tr&gt;');
 						r.push('&lt;td class="tablehead" colspan="2"&gt;');
 						r.push(getTranslationByName("category",translations));
 						r.push('&lt;/td&gt;');
 						r.push('&lt;td class="tablehead" colspan="' + colWidth/3 + '"&gt;');
 						r.push(getTranslationByName("person",translations));
 						r.push('&lt;/td&gt;');
 						r.push('&lt;td class="tablehead" colspan="' + colWidth/3 + '"&gt;');
 						r.push(getTranslationByName("place",translations));
 						r.push('&lt;/td&gt;');
 						r.push('&lt;td class="tablehead" colspan="' + colWidth/3 + '"&gt;');
 						r.push(getTranslationByName("thing",translations));
 						r.push('&lt;/td&gt;');
 						r.push('&lt;/tr&gt;');
 						
 						r.push('&lt;tr&gt;');
 						r.push('&lt;td class="tablehead" colspan="2"&gt;');
 						r.push(getTranslationByName("playWords",translations));
 						r.push('&lt;/td&gt;');
						for(var i = 0; i &lt; outcomeWords.length; ++i)
						{
							var word = outcomeWords[i];
							if(checkMatched(outcomeWords[i], playLetters))
							{
								word = getTranslationByName("youMatched",translations) + ": " + word;
							}
							r.push('&lt;td class="tablebody" colspan="' + colWidth/(outcomeWords.length) + '"&gt;');
							r.push(word);
							r.push('&lt;/td&gt;');
							registerDebugText("Word[" + i + "]: " + word);
						}
						r.push('&lt;/tr&gt;');
						
						r.push('&lt;tr&gt;');
						r.push('&lt;td class="tablehead" colspan="2"&gt;');
 						r.push(getTranslationByName("value",translations));
 						r.push('&lt;/td&gt;');
 						for(var i = 0; i &lt; outcomePrizes.length; ++i)
 						{
 							var prizeValue = convertedPrizeValues[getPrizeNameIndex(prizeNamesList, outcomePrizes[i])];
							r.push('&lt;td class="tablebody" colspan="' + colWidth/(outcomePrizes.length) + '"&gt;');
							r.push(prizeValue);
							r.push('&lt;/td&gt;');
							registerDebugText("Prize " + outcomePrizes[i] + ": " + prizeValue);
 						}
						r.push('&lt;/tr&gt;');
						
						r.push('&lt;tr&gt;');
						r.push('&lt;td class="tablehead" colspan="2"&gt;');
 						r.push(getTranslationByName("playLetters",translations));
 						r.push('&lt;/td&gt;');
 						for(var i = 0; i &lt; playLetters.length; ++i)
 						{
 							if(!isNaN(playLetters[i]))
 							{
 								continue;
 							}
							r.push('&lt;td class="tablebody"&gt;');
							r.push(playLetters[i]);
							r.push('&lt;/td&gt;');
 						}
						r.push('&lt;/tr&gt;');
						
						if(!isNaN(multiplier))
						{
							r.push('&lt;tr&gt;');
							r.push('&lt;td class="tablehead" colspan="2"&gt;');
	 						r.push(getTranslationByName("multiplier",translations));
	 						r.push('&lt;/td&gt;');
							r.push('&lt;td class="tablebody" colspan="' + colWidth + '"&gt;');
							r.push(multiplier + "x");
							r.push('&lt;/td&gt;');
							r.push('&lt;/tr&gt;');
						}
						
						r.push('&lt;/table&gt;');
						
						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
							for(var idx = 0; idx &lt; debugFeed.length; ++idx)
							{
								if(debugFeed[idx] == "")
									continue;
								r.push('&lt;tr&gt;');
								r.push('&lt;td class="tablebody"&gt;');
								r.push(debugFeed[idx]);
								r.push('&lt;/td&gt;');
								r.push('&lt;/tr&gt;');
							}
							r.push('&lt;/table&gt;');
						}

						return r.join('');
					}
					
					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}
					
					// Input: Json document string containing 'amount' at root level.
					// Output: Price Point value.
					function getPricePoint(jsonContext)
					{
						// Parse json and retrieve price point amount
						var jsObj = JSON.parse(jsonContext);
						var pricePoint = jsObj.amount;

						return pricePoint;
					}

					// Input: e.g. "W1:16|EXAMINER:H,ISTANBUL:M,COMPLAINT:C|B,V,N,U,S,F,W,T,L,A,C,I,2"
					// Output: e.g. ["EXAMINER", "ISTANBUL", "COMPLAINT"] or ["H", "M", "C"]
					function getWOFOutcomeData(scenario, index)
					{
						var outcomeData = scenario.split("|")[1];
						var outcomePairs = outcomeData.split(",");
						var result = [];
						for(var i = 0; i &lt; outcomePairs.length; ++i)
						{
							result.push(outcomePairs[i].split(":")[index]);
						}
						return result;
					}
					
					// Input: e.g. "W1:16|EXAMINER:H,ISTANBUL:M,COMPLAINT:C|B,V,N,U,S,F,W,T,L,A,C,I,2"
					// Output: e.g. ["B","V","N","U","S",...]
					function getPlayLetters(scenario)
					{
						var outcomeData = scenario.split("|")[2];
						return outcomeData.split(",");
					}
					
					// Input: "A,B,C,D,..." and "A"
					// Output: index number
					function getPrizeNameIndex(prizeNames, currPrize)
					{
						var prizes = prizeNames;
						
						for(var i = 0; i &lt; prizes.length; ++i)
						{
							if(prizes[i] == currPrize)
							{
								return i;
							}
						}
						
						return -1;
					}
					
					function checkMatched(word, letters)
					{
						var letterString = letters.join("");
						for(var i = 0; i &lt; word.length; ++i)
						{
							if(letterString.indexOf(word[i]) == -1)
							{
								return false;
							}
						}
						return true;
					}
					
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// Input: A list of Price Points and the available Prize Structures for the game as well as the wagered price point
					// Output: A string of the specific prize structure for the wagered price point
					function retrievePrizeTable(pricePoints, prizeTables, wageredPricePoint)
					{
						var pricePointList = pricePoints.split(",");
						var prizeTableStrings = prizeTables.split("|");						
						
						for(var i = 0; i &lt; pricePoints.length; ++i)
						{
							if(wageredPricePoint == pricePointList[i])
							{
								return prizeTableStrings[i];
							}
						}
						
						return "";
					}
					
					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}
					
					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
                    {
                        var index = 1;
                        while(index &lt; translationNodeSet.item(0).getChildNodes().getLength())
                        {
                            var childNode = translationNodeSet.item(0).getChildNodes().item(index);
 
                            if(childNode.name == "phrase" &amp;&amp; childNode.getAttribute("key") == keyName)
                            {
                                registerDebugText("Child Node: " + childNode.name);
                                return childNode.getAttribute("value");
                            }
                                          
                            index += 1;
                        }
                    }
					
				</lxslt:script>
</lxslt:component>
<xsl:template match="root" mode="last">
<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWager']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWins']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
</table>
</xsl:template>
<xsl:template match="//Outcome">
<xsl:if test="OutcomeDetail/Stage = 'Scenario'">
<xsl:call-template name="Scenario.Detail"/>
</xsl:if>
</xsl:template>
<xsl:template name="Scenario.Detail">
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
<tr>
<td class="tablebold" background="">
<xsl:value-of select="//translation/phrase[@key='transactionId']/@value"/>
<xsl:value-of select="': '"/>
<xsl:value-of select="OutcomeDetail/RngTxnId"/>
</td>
</tr>
</table>
<xsl:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())"/>
<xsl:variable name="translations" select="lxslt:nodeset(//translation)"/>
<xsl:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)"/>
<xsl:variable name="prizeTable" select="lxslt:nodeset(//lottery)"/>
<xsl:variable name="convertedPrizeValues">
<xsl:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
</xsl:variable>
<xsl:variable name="prizeNames">
<xsl:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
</xsl:variable>
<xsl:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes"/>
</xsl:template>
<xsl:template match="prize" mode="PrizeValue">
<xsl:text>|</xsl:text>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="text()"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</xsl:template>
<xsl:template match="description" mode="PrizeDescriptions">
<xsl:text>,</xsl:text>
<xsl:value-of select="text()"/>
</xsl:template>
<xsl:template match="text()"/>
</xsl:stylesheet>
