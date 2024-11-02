<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="anything">
	<xsl:namespace-alias stylesheet-prefix="x" result-prefix="xsl" />
	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	<xsl:include href="../utils.xsl" />

	<xsl:template match="/Paytable">
		<x:stylesheet version="1.0" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="java" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:my-ext="ext1" extension-element-prefixes="my-ext">
			<x:import href="HTML-CCFR.xsl" />
			<x:output indent="no" method="xml" omit-xml-declaration="yes" />

			<!-- TEMPLATE Match: -->
			<x:template match="/">
				<x:apply-templates select="*" />
				<x:apply-templates select="/output/root[position()=last()]" mode="last" />
				<br />
			</x:template>

			<!--The component and its script are in the lxslt namespace and define the implementation of the extension. -->
			<lxslt:component prefix="my-ext" functions="formatJson retrievePrizeTable">
				<lxslt:script lang="javascript">
					<![CDATA[
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
						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
						
						r.push('<tr>');
 						r.push('<td class="tablehead" colspan="2">');
 						r.push(getTranslationByName("category",translations));
 						r.push('</td>');
 						r.push('<td class="tablehead" colspan="' + colWidth/3 + '">');
 						r.push(getTranslationByName("person",translations));
 						r.push('</td>');
 						r.push('<td class="tablehead" colspan="' + colWidth/3 + '">');
 						r.push(getTranslationByName("place",translations));
 						r.push('</td>');
 						r.push('<td class="tablehead" colspan="' + colWidth/3 + '">');
 						r.push(getTranslationByName("thing",translations));
 						r.push('</td>');
 						r.push('</tr>');
 						
 						r.push('<tr>');
 						r.push('<td class="tablehead" colspan="2">');
 						r.push(getTranslationByName("playWords",translations));
 						r.push('</td>');
						for(var i = 0; i < outcomeWords.length; ++i)
						{
							var word = outcomeWords[i];
							if(checkMatched(outcomeWords[i], playLetters))
							{
								word = getTranslationByName("youMatched",translations) + ": " + word;
							}
							r.push('<td class="tablebody" colspan="' + colWidth/(outcomeWords.length) + '">');
							r.push(word);
							r.push('</td>');
							registerDebugText("Word[" + i + "]: " + word);
						}
						r.push('</tr>');
						
						r.push('<tr>');
						r.push('<td class="tablehead" colspan="2">');
 						r.push(getTranslationByName("value",translations));
 						r.push('</td>');
 						for(var i = 0; i < outcomePrizes.length; ++i)
 						{
 							var prizeValue = convertedPrizeValues[getPrizeNameIndex(prizeNamesList, outcomePrizes[i])];
							r.push('<td class="tablebody" colspan="' + colWidth/(outcomePrizes.length) + '">');
							r.push(prizeValue);
							r.push('</td>');
							registerDebugText("Prize " + outcomePrizes[i] + ": " + prizeValue);
 						}
						r.push('</tr>');
						
						r.push('<tr>');
						r.push('<td class="tablehead" colspan="2">');
 						r.push(getTranslationByName("playLetters",translations));
 						r.push('</td>');
 						for(var i = 0; i < playLetters.length; ++i)
 						{
 							if(!isNaN(playLetters[i]))
 							{
 								continue;
 							}
							r.push('<td class="tablebody">');
							r.push(playLetters[i]);
							r.push('</td>');
 						}
						r.push('</tr>');
						
						if(!isNaN(multiplier))
						{
							r.push('<tr>');
							r.push('<td class="tablehead" colspan="2">');
	 						r.push(getTranslationByName("multiplier",translations));
	 						r.push('</td>');
							r.push('<td class="tablebody" colspan="' + colWidth + '">');
							r.push(multiplier + "x");
							r.push('</td>');
							r.push('</tr>');
						}
						
						r.push('</table>');
						
						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
							for(var idx = 0; idx < debugFeed.length; ++idx)
							{
								if(debugFeed[idx] == "")
									continue;
								r.push('<tr>');
								r.push('<td class="tablebody">');
								r.push(debugFeed[idx]);
								r.push('</td>');
								r.push('</tr>');
							}
							r.push('</table>');
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
						for(var i = 0; i < outcomePairs.length; ++i)
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
						
						for(var i = 0; i < prizes.length; ++i)
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
						for(var i = 0; i < word.length; ++i)
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
						
						for(var i = 0; i < pricePoints.length; ++i)
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
                        while(index < translationNodeSet.item(0).getChildNodes().getLength())
                        {
                            var childNode = translationNodeSet.item(0).getChildNodes().item(index);
 
                            if(childNode.name == "phrase" && childNode.getAttribute("key") == keyName)
                            {
                                registerDebugText("Child Node: " + childNode.name);
                                return childNode.getAttribute("value");
                            }
                                          
                            index += 1;
                        }
                    }
					]]>
				</lxslt:script>
			</lxslt:component>

			<x:template match="root" mode="last">
				<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWager']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWins']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
				</table>
			</x:template>

			<!-- TEMPLATE Match: digested/game -->
			<x:template match="//Outcome">
				<x:if test="OutcomeDetail/Stage = 'Scenario'">
					<x:call-template name="Scenario.Detail" />
				</x:if>
			</x:template>

			<!-- TEMPLATE Name: Wager.Detail (base game) -->
			<x:template name="Scenario.Detail">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='transactionId']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="OutcomeDetail/RngTxnId" />
						</td>
					</tr>
				</table>

			<!-- TEMPLATE Name: LastEvaluation.Detail (Wager in Try Mode, Reveal in Buy Mode) -->
				<x:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())" />
				<x:variable name="translations" select="lxslt:nodeset(//translation)" />
				<x:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)" />
				<x:variable name="prizeTable" select="lxslt:nodeset(//lottery)" />

				<x:variable name="convertedPrizeValues">

					<x:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
				</x:variable>

				<x:variable name="prizeNames">
					<x:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
				</x:variable>


				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes" />
			</x:template>

			<x:template match="prize" mode="PrizeValue">
					<x:text>|</x:text>
					<x:call-template name="Utils.ApplyConversionByLocale">
						<x:with-param name="multi" select="/output/denom/percredit" />
					<x:with-param name="value" select="text()" />
						<x:with-param name="code" select="/output/denom/currencycode" />
						<x:with-param name="locale" select="//translation/@language" />
					</x:call-template>
			</x:template>
			<x:template match="description" mode="PrizeDescriptions">
				<x:text>,</x:text>
				<x:value-of select="text()" />
			</x:template>

			<x:template match="text()" />
		</x:stylesheet>
	</xsl:template>

	<xsl:template name="TemplatesForResultXSL">
		<x:template match="@aClickCount">
			<clickcount>
				<x:value-of select="." />
			</clickcount>
		</x:template>
		<x:template match="*|@*|text()">
			<x:apply-templates />
		</x:template>
	</xsl:template>
</xsl:stylesheet>
