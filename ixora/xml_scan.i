/* xml_scan.i
 * MODULE
        Вспомогательные функции для работы с XML
 * DESCRIPTION
        Вспомогательные функции для работы с XML
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        24/07/06 tsoy
 * CHANGES
        19/03/2008 madiyar - закомментировал две последние функции, обращающиеся к таблице uid-jh (БД ELX)
        17/02/2010 madiyar - переименован из старой версии xml.i
*/

def stream  log-stream.

procedure x_log:

def input parameter fname    as char.
def input parameter s1       as char.
def input parameter s2       as char.

    output stream log-stream to value( "/tmp/" + fname + '.log') append no-echo.
    put stream log-stream unformatted string(today ) + ' ' + string( time, 'hh:mm:ss' ) + ' '
    s1 format 'x(22)'
    s2
    skip.
    output stream log-stream close.

end procedure.

procedure get-attr.

    def input  param p-in as handle.
    def input  param p-name as char.
    def input  param p-attr as char.
    def output param p-out as char.

    def var v-res as logi.

    v-res = false.

    def var h-root as handle.

    create x-noderef h-root no-error.

    p-in:get-document-element (h-root).

    /* в том случае есди искомая нода как root */
    if h-root:name = p-name then do:

        p-out = h-root:get-attribute (p-attr).
        v-res = true.
        return.

    end.

    if h-root:num-children < 1 then return.

    run find-child(input h-root, input-output p-name, input-output p-attr, input-output v-res, input-output p-out) .

    if v-res then do:

         if p-out = "" then
             return error 'Attribute empty ' + p-name + '->' + p-attr + ' (700001)'.
         else
             return.
    end.

/*  return error 'Узел не найден (700004)'.*/
    return error 'Attribute not found ' + p-name + '->' + p-attr + ' (700002)'.

end.

procedure find-child.

    def input  param p-root as handle.
    def input-output param p-name as char.
    def input-output param p-attr as char.
    def input-output param p-res as logi.
    def input-output param p-out as char.

    def var i as int.
    def var h-child-node as handle.
    create x-noderef h-child-node no-error.

    if p-root:name = p-name then do:
               p-out = p-root:get-attribute (p-attr).
               p-res = true.
               return.
    end.

    if p-root:num-children > 0  then do:

       do i = 1 to p-root:num-children.
           p-root:get-child(h-child-node, i).
           run find-child(input h-child-node, input-output p-name, input-output p-attr, input-output p-res, input-output p-out) .
       end.

    end.

end.

procedure get-node.

    def input  param p-in as handle.
    def input  param p-name as char.
    def output param p-out as char.

    def var v-res as logi.

    v-res = false.

    def var h-root as handle.
    def var h-child-node as handle.
    create x-noderef h-child-node no-error.

    def var h-child-node-value as handle.
    create x-noderef h-child-node-value no-error.


    create x-noderef h-root no-error.

    p-in:get-document-element (h-root).



    /* в том случае есди искомая нода как root */
    if h-root:name = p-name then do:

        h-root:get-child (h-child-node-value,1).
        p-out = h-child-node-value:node-value.
        v-res = true.
        return.

    end.

    if h-root:num-children < 1 then return.

    run find-child-node(input h-root, input-output p-name, input-output v-res, input-output p-out) .

    if v-res then do:

         if p-out = "" then
             return error 'Узел  пуст ' + p-name +  ' (700001)'.
         else
             return.
    end.

/*  return error 'Узел не найден (700004)'.*/
    return error 'Узел не найден ' + p-name +  ' (700002)'.

end.

procedure find-child-node.

    def input  param p-root as handle.
    def input-output param p-name as char.
    def input-output param p-res as logi.
    def input-output param p-out as char.

    def var i as int.
    def var h-child-node as handle.
    create x-noderef h-child-node no-error.

    def var h-child-node-value as handle.
    create x-noderef h-child-node-value no-error.


    if p-root:name = p-name then do:
               p-root:get-child (h-child-node-value,1).
               p-out = h-child-node-value:node-value.
               p-res = true.
               return.
    end.

    if p-root:num-children > 0  then do:

       do i = 1 to p-root:num-children.
           p-root:get-child(h-child-node, i).
           run find-child-node(input h-child-node, input-output p-name, input-output p-res, input-output p-out) .
       end.

    end.

end.


function get-amount returns char (v as decimal).
    return replace(replace(string(v, '->>>>>>>>>>>>>>>>>>>>>>>9.99'), ' ', ''), ".",",").
end.

function is-correct-amount returns logical (v as char, nd as int).
    if v matches ',' then
        return false.
    if v matches ' ' then
        return false.

    def var v-d as decimal.

    v-d = decimal(v) no-error.
    if error-status:error then
        return false.

    if v-d <> truncate(v-d, nd) then
        return false.

    return true.
end.

function get-datetime returns char (v-dat as date, v-tim as int).
    return string(year(v-dat), '9999') + '-' +
           string(month(v-dat), '99') + '-' +
           string(day(v-dat), '99') + ' ' +
           string(v-tim, 'HH:MM:SS').
end.


function get-dat-datetime returns date (v-datetime as char).

    def var v-dat as char.
    v-dat = entry(1, v-datetime, ' ') no-error.

    return date(integer(entry(2, v-dat, '-')), integer(entry(3, v-dat, '-')), integer(entry(1, v-dat, '-'))).
end.

function get-tim-datetime returns int (v-datetime as char).

    def var v-tim as char.
    v-tim = entry(2, v-datetime, ' ') no-error.

    return integer(entry(1, v-tim, ':')) * 3600 +
           integer(entry(2, v-tim, ':')) * 60 +
           integer(entry(3, v-tim, ':')).
end.

procedure add-root.

def input  param p-x-doc as handle.
def input  param p-x-doc-root-elem-name  as char.
def input-output param p-x-doc-root-elem as handle.

p-x-doc:create-node (p-x-doc-root-elem, p-x-doc-root-elem-name, "ELEMENT").
p-x-doc:append-child (p-x-doc-root-elem).

end procedure.

procedure add-element.

def input  param p-x-doc as handle.
def input  param p-x-doc-elem-name as char.
def input  param p-x-doc-elem-type as char.
def input-output param p-x-doc-parent-elem as handle.
def input-output param p-x-doc-child-elem as handle.

def var v-parent-child as handle.
create x-noderef v-parent-child.


if p-x-doc-elem-type = "TEXT" then do:

   p-x-doc:create-node (v-parent-child, p-x-doc-elem-name, "ELEMENT").
   p-x-doc-parent-elem:append-child (v-parent-child).

   p-x-doc:create-node (p-x-doc-child-elem, "", p-x-doc-elem-type).
   v-parent-child:append-child (p-x-doc-child-elem).

end.

if p-x-doc-elem-type = "ELEMENT" then do:
   p-x-doc:create-node (p-x-doc-child-elem, p-x-doc-elem-name, "ELEMENT").
   p-x-doc-parent-elem:append-child (p-x-doc-child-elem).

end.


end procedure.

/*
function is-process-uid logical (input p-uid as char).

  find first uid-jh where uid-jh.uid = p-uid and uid-jh.jh > 0  no-lock no-error.
  if avail uid-jh then
      return true.
  else
      return false.

end function.

procedure insert-uid.
 def input parameter  p-uid as char .
 def input parameter  p-jh as integer.
 def input parameter  p-xdoc as integer .
 def input parameter  p-type as char.
 def input parameter  p-sender-id as char .
 def input parameter  p-amt as deci.
 def input parameter  p-comm as deci.


   create uid-jh.
     assign
        uid-jh.dt           = today
        uid-jh.uid          = p-uid
        uid-jh.jh           = p-jh
        uid-jh.xdoc-id      = p-xdoc
        uid-jh.xdoc-type    = p-type
        uid-jh.terminal-id  = p-sender-id
        uid-jh.amt          = p-amt
        uid-jh.comm         = p-comm.

  release uid-jh.

end procedure.
*/

