/* XMLParser.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        29.04.2013 evseev tz-1810
 * BASES
        BANK
 * CHANGES
*/

def var iLevel as int no-undo.
def var Parentname as char no-undo.
def temp-table nodes no-undo
  field name as char
  field nodevalue as char
  field parent as char
  field level as int.
def shared var filename as char no-undo.
def shared temp-table xmlpars no-undo
  field par as char
  field val as char.

run ProcessXML( input filename ).
run createXmlPars.

procedure ProcessXML:
  def input parameter XMLfilename as char no-undo.
  def var hXML as handle no-undo.
  def var hRoot as handle no-undo.
  empty temp-table nodes.
  create x-document hXML.
  create x-noderef hRoot.
  hXML:load('FILE':U, XMLfilename , false).
  hXML:get-document-element(hRoot).
  parentname = "ROOT".
  run process-children( input hRoot ).
  delete object hXML.
  delete object hRoot.
end. /* processXML */

procedure process-children:
  def input parameter hparent as handle no-undo.
  def var hChild as handle no-undo.
  def var i as int no-undo.
  iLevel = iLevel + 1.
  create x-noderef hChild.
  create nodes.
  assign
   nodes.name = hparent:name
   nodes.parent = parentname
   nodes.level = iLevel.
  run processAttributes( input hparent ).
  do i = 1 to hparent:num-children :
       hparent:get-child(hChild,i).
       if hChild:name = "#text" then do:
          assign nodes.nodevalue = hChild:node-value.
       end. else do:
          parentname = hparent:name.
          run process-children( input hChild ).
       end.
  end.
  iLevel = iLevel - 1.
  delete object hChild.
end. /* process-child */

procedure processAttributes:
  def input parameter hparent as handle no-undo.
  def var cAttribute as char no-undo.
  def var i as int no-undo.
  def buffer nodes for nodes.
  do i = 1 to num-entries(hparent:attribute-names) transaction:
       cAttribute = entry(i,hparent:attribute-names).
       create nodes.
       assign
        nodes.name = cAttribute
        nodes.parent = hparent:name
        nodes.nodevalue = hparent:get-attribute(cAttribute)
        nodes.level = iLevel + 1.
  end.
end. /* processAttributes */

procedure createXmlPars:
   def var lev as char extent 15.
   def var str as char.
   def var i as int.
   do i = 1 to 15: lev[i] = "". end.
   empty temp-table xmlpars.
   for each nodes:
      lev[nodes.level] = CODEPAGE-CONVERT(nodes.name,"kz-1048","utf-8").
      do i = nodes.level + 1 to 15: lev[i] = "". end.
      do i = 1 to 15: str = str + lev[i] + " ". end.
      str = trim (str).
      create xmlpars.
      assign xmlpars.par = str xmlpars.val = trim(CODEPAGE-CONVERT(nodes.nodevalue,"kz-1048","utf-8")).
      str = "".
   end.
end.