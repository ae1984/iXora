/* xml.i
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
*/

def stream  log-stream.




procedure get-valuenode. 

    def input  param p-in as handle.
    def var v-res as logi.

    v-res = false.
    def var h-root as handle.
    def var h-child-node as handle.
    create x-noderef h-child-node no-error.
    def var h-child-node-value as handle.
    create x-noderef h-child-node-value no-error.
    create x-noderef h-root no-error.
    p-in:get-document-element (h-root).
    if h-root:num-children < 1 then return.

    run find-child-nodemail(input h-root) . 

    return.
end. 

procedure find-child-nodemail.
    def input  param p-root as handle.
    def var i as int.
    def var q as int.
    def var h-child-node as handle.
    create x-noderef h-child-node no-error.
    def var h-child-node-value as handle.
    create x-noderef h-child-node-value no-error.


    if p-root:num-children < 1 then return.
   if p-root:name = "ID"              then do: p-root:get-child (h-child-node-value,1). m_id = h-child-node-value:node-value.              end. else
   if p-root:name = "BANK_ID"         then do: p-root:get-child (h-child-node-value,1). m_BANK_ID = h-child-node-value:node-value.         end. else
   if p-root:name = "NUM_DOC"         then do: p-root:get-child (h-child-node-value,1). m_NUM_DOC = h-child-node-value:node-value.         end. else
   if p-root:name = "DATE_DOC"        then do: p-root:get-child (h-child-node-value,1). m_DATE_DOC = h-child-node-value:node-value.        end. else
   if p-root:name = "PAYER_NAME"      then do: p-root:get-child (h-child-node-value,1). m_PAYER_NAME = h-child-node-value:node-value.      end. else
   if p-root:name = "PAYER_RNN"       then do: p-root:get-child (h-child-node-value,1). m_PAYER_RNN = h-child-node-value:node-value.       end. else
   if p-root:name = "PAYER_ACCOUNT"   then do: p-root:get-child (h-child-node-value,1). m_PAYER_ACCOUNT = h-child-node-value:node-value.   end. else
   if p-root:name = "PAYER_CODE"      then do: p-root:get-child (h-child-node-value,1). m_PAYER_CODE = h-child-node-value:node-value.      end. else
   if p-root:name = "PAYER_BANK_BIC"  then do: p-root:get-child (h-child-node-value,1).  m_PAYER_BANK_BIC = h-child-node-value:node-value. end. else
   if p-root:name = "PAYER_BANK_NAME" then do: p-root:get-child (h-child-node-value,1). m_PAYER_BANK_NAME = h-child-node-value:node-value. end. else
   if p-root:name = "PRIORITY"        then do: p-root:get-child (h-child-node-value,1). m_PRIORITY = h-child-node-value:node-value.        end. else
   if p-root:name = "THEME"           then do: p-root:get-child (h-child-node-value,1). m_THEME = h-child-node-value:node-value.           end. else
   if p-root:name = "MESSAGE_BODY"    then do: p-root:get-child (h-child-node-value,1). m_MESSAGE_BODY = h-child-node-value:node-value.    end. else
   if p-root:name = "CLIENT_COMMENTS" then do: p-root:get-child (h-child-node-value,1). m_CLIENT_COMMENTS = h-child-node-value:node-value. end. else
   if p-root:name = "STATUS"          then do: p-root:get-child (h-child-node-value,1). m_STATUS = h-child-node-value:node-value.          end. else
   if p-root:name = "TOTAL_COUNT"     then do: p-root:get-child (h-child-node-value,1). m_TOTAL_COUNT = h-child-node-value:node-value.     end. else
   if p-root:name = "FILE_NAME" then do:
      ii = ii + 1.
      p-root:get-child (h-child-node-value,1). m_FILE_NAME[ii] = h-child-node-value:node-value.
   end. else
   if p-root:name = "FILE_SIZE" then do:
      p-root:get-child (h-child-node-value,1). m_FILE_SIZE[ii] = h-child-node-value:node-value.
   end. else
   if p-root:name = "DATA" then do:
      p-root:get-child (h-child-node-value,1). 
/*      m_DATA[ii] = h-child-node-value:node-value. */
      h-child-node-value:node-value-to-longchar(m_DATA[ii]).
   end. 



    if p-root:num-children > 1  then do:
       do q = 1 to p-root:num-children.
           p-root:get-child(h-child-node, q).
           run find-child-nodemail(input h-child-node). 
       end.
    end.
end.







