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
        14/09/2012 madiyar UTF8 -> KZ1048, longhar -> memptr
        28/09/2012 madiyar - очистка переменной memptr
        13.03.2013 damir - Внедрено Т.З. № 1558,1582. Добавил GetParamValueOne,GetParamValueTwo.
        12/09/2013 k.gitalov добавление функции GetLongParamValueOne returns longchar 
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
  index idx2 nodeParentId nodeName.

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
    /*
    def input parameter charXML as longchar no-undo.
    def output parameter errDes as char no-undo.
    errDes = ''.
    empty temp-table t-node.
    empty temp-table t-nodeAttr.
    create x-document hdoc.
    v-xml_ok = hdoc:load("longchar", charXML, false) no-error.
    if not (v-xml_ok) then errDes = "XML-document loaded with errors".
    else do:
        create x-noderef hroot.
        hdoc:get-document-element(hroot).
        run parseNode(hroot,0,0).
    end.
    */
    def input parameter charXML as char no-undo.
    def output parameter errDes as char no-undo.
    errDes = ''.
    define var memptrXML as memptr.
    set-size(memptrXML) = 0. /* нужно обязательно, для очистки памяти от прежних документов */
    set-size(memptrXML) = length(charXML) + 1.
    put-string(memptrXML, 1) = charXML.

    empty temp-table t-node.
    empty temp-table t-nodeAttr.
    create x-document hdoc.
    v-xml_ok = hdoc:load("memptr", memptrXML, false) no-error.
    if not (v-xml_ok) then errDes = "XML-document loaded with errors".
    else do:
        create x-noderef hroot.
        hdoc:get-document-element(hroot).
        run parseNode(hroot,0,0).
    end.
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
    else do:
        create x-noderef hroot.
        hdoc:get-document-element(hroot).
        run parseNode(hroot,0,0).
    end.
end procedure.

procedure parseMemptrXML:
    def input parameter memptrXML as memptr no-undo.
    def output parameter errDes as char no-undo.
    errDes = ''.
    empty temp-table t-node.
    empty temp-table t-nodeAttr.
    create x-document hdoc.
    v-xml_ok = hdoc:load("memptr", memptrXML, false) no-error.
    if not (v-xml_ok) then errDes = "XML-document loaded with errors".
    else do:
        create x-noderef hroot.
        hdoc:get-document-element(hroot).
        run parseNode(hroot,0,0).
    end.
end procedure.

function cp-convert returns char (input parm1 as char).
    def var res as char no-undo.
    res = CODEPAGE-CONVERT(parm1,"kz-1048","utf-8").
    return res.
end function.

function GetParamValueOne returns char (input ParamData as char,input ParamName as char).
    def var v-res as char.
    def var p-int1 as inte.
    def var p-int2 as inte.
    def var c-par1 as char.
    def var c-par2 as char.

    v-res = "".
    ParamData = trim(ParamData).
    c-par1 = "<" + ParamName + ">".
    c-par2 = "</" + ParamName + ">".

    p-int1 = index(ParamData,c-par1) + length(c-par1).
    p-int2 = index(ParamData,c-par2).

    if p-int1 <> 0 and p-int2 <> 0 then v-res = trim(substr(ParamData,p-int1,p-int2 - p-int1)).

    return v-res.
end function.

function GetLongParamValueOne returns longchar (input ParamData as longchar,input ParamName as char).
    def var v-res as char.
    def var p-int1 as inte.
    def var p-int2 as inte.
    def var c-par1 as char.
    def var c-par2 as char.

    v-res = "".
    ParamData = trim(ParamData).
    c-par1 = "<" + ParamName + ">".
    c-par2 = "</" + ParamName + ">".

    p-int1 = index(ParamData,c-par1) + length(c-par1).
    p-int2 = index(ParamData,c-par2).

    if p-int1 <> 0 and p-int2 <> 0 then v-res = trim(substr(ParamData,p-int1,p-int2 - p-int1)).

    return v-res.
end function.

function GetParamValueTwo returns char(input ParamData as char,input ParamName as char).
    def var v-res as char.
    def var v-str as char extent 2.
    def var c-par1 as char.
    def var c-par2 as char.

    v-res = "". v-str = "".
    ParamData = trim(ParamData).
    c-par1 = "<" + ParamName.
    c-par2 = "</" + ParamName + ">".

    if index(ParamData,c-par1) gt 0 and index(ParamData,c-par2) gt 0 then do:
        v-str[1] = trim(substr(ParamData,index(ParamData,c-par1),index(ParamData,c-par2) - index(ParamData,c-par1))).
        if index(v-str[1],">") gt 0 then v-str[2] = trim(substr(v-str[1],index(v-str[1],">") + 1,length(v-str[1]))).
    end.
    v-res = v-str[2].

    return v-res.
end function.

