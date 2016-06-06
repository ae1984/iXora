/* xmlParser.i
 * MODULE
        Программы общего назначения
 * DESCRIPTION
        Парсер XML-документов
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
        17/02/2010 madiyar
 * BASES
        BANK
 * CHANGES
*/

def var hDoc as handle.
def var hRoot as handle.
def var v-xml_ok as logi no-undo.
def var v-lastUsedNodeId as integer no-undo.
v-lastUsedNodeId = 0.

def temp-table t-node no-undo
  field nodeId as integer
  field nodeName as char
  field nodeParentId as integer
  field nodeLevel as integer
  field nodeValue as char
  field numChildren as integer
  index idx1 is primary nodeId
/*
  index idx2 nodeParentId nodeName.
*/
index idx2 nodeParentId nodeId.

def temp-table t-nodeAttr no-undo
  field nodeId as integer
  field nodeAttrName as char
  field nodeAttrValue as char
  index idx1 is primary nodeId.

procedure parseNode:
    def input parameter p-node as handle.
    def input parameter p-nodeParentId as integer no-undo.
    def input parameter p-nodeLevel as integer no-undo.

    def var v-childNode as handle.
    create x-noderef v-childNode.
    def var v-currentNodeId as integer no-undo.
    def var coun_k as integer.
    def var v-attrNames as char no-undo.
    def var v-aName as char no-undo.

    create t-node.
    v-lastUsedNodeId = v-lastUsedNodeId + 1.
    v-currentNodeId = v-lastUsedNodeId.

    assign t-node.nodeId = v-currentNodeId
           t-node.nodeName = p-node:name
           t-node.nodeParentId = p-nodeParentId
           t-node.nodeLevel = p-nodeLevel
           t-node.nodeValue = p-node:node-value
           t-node.numChildren = p-node:num-children.

    v-attrNames = p-node:attribute-names.
    repeat coun_k = 1 to num-entries(v-attrNames):
        v-aName = entry(coun_k,v-attrNames).
        create t-nodeAttr.
        assign t-nodeAttr.nodeId = v-currentNodeId
               t-nodeAttr.nodeAttrName = v-aName
               t-nodeAttr.nodeAttrValue = p-node:get-attribute(v-aName).
    end.

    if p-node:num-children > 0 then do:
        repeat coun_k = 1 to p-node:num-children:
            if not p-node:get-child(v-childNode,coun_k) then leave.
            else do:
                if v-childNode:name = "#text" then do:
                    find first t-node where t-node.nodeId = v-currentNodeId.
                    t-node.nodeValue = t-node.nodeValue + v-childNode:node-value.
                end.
                else run parseNode(v-childNode,v-currentNodeId,p-nodeLevel + 1).
            end.
        end.
    end.

end procedure.

procedure parseCharXML:
    def input parameter charXML as longchar no-undo.
    def output parameter errDes as char no-undo.
    errDes = ''.
    empty temp-table t-node.
    empty temp-table t-nodeAttr.
    create x-document hdoc.
    v-xml_ok = hdoc:load("longchar", charXML, false) no-error.
    if not (v-xml_ok) then errDes = "XML-document loaded with errors".
    create x-noderef hroot.
    hdoc:get-document-element(hroot).
    run parseNode(hroot,0,0).
end procedure.

procedure parseFileXML:
    def input parameter fileXML as char no-undo.
    def output parameter errDes as char no-undo.
    errDes = ''.
    empty temp-table t-node.
    empty temp-table t-nodeAttr.
    create x-document hdoc.
    v-xml_ok = hdoc:load("file", fileXML, false) no-error.
    if not (v-xml_ok) then errDes = "XML-document loaded with errors".
    create x-noderef hroot.
    hdoc:get-document-element(hroot).
    run parseNode(hroot,0,0).
end procedure.

