/* dsrcont.i
 * MODULE
        Клиентская база
 * DESCRIPTION
        Контроль привязки кода клиента к  списку документов       
        
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-6
 * AUTHOR
        11.02.2005 marinav
 * CHANGES
        15.06.05 marinav - добавила 3 параметр в run dsrview ( 0 - не надо проверять акцепт на документах) 
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
*/

{mainhead.i}

{dsr.i "new"}

def var v-select as integer.
def var v-cif as char.
def var v-cifname as char.
def var ja as log format "да/нет" init no.
def var v-ourbank as char.

find sysc where sysc.sysc = "OURBNK" no-lock no-error.
if avail sysc then v-ourbank = trim(sysc.chval).


repeat:
  v-select = 0.
  run sel2 (" ХРАНИЛИЩЕ ДОСЬЕ КЛИЕНТОВ ", 
            " 1. Список новых документов| 2. Акцепт новых документов| 3. Список удаленных документов| 4. Акцепт удаленных документов|     ВЫХОД ", 
            output v-select).

  if v-select = 0 or v-select = 5 then return.

  case v-select:
    when 1 then run dsrlist( 2 ).

    when 2 then do:

         v-cif = "".
         v-cifname = "".
       
         def frame f-client 
           v-cif label "КЛИЕНТ " format "x(6)" colon 10 help " Введите код клиента (F2 - поиск)"
             validate (can-find(first cif where cif.cif = v-cif no-lock), " Клиент с таким кодом не найден!")
           v-cifname no-label format "x(45)" colon 18
           with side-label row 5 no-box.
         
         repeat on endkey undo, return:
           update v-cif with frame f-client.
         
           find first cif where cif.cif = v-cif no-lock no-error.
           v-cifname = trim((cif.prefix) + " " + trim(cif.name)).
         
           displ v-cifname with frame f-client.
         
           run dsrview (v-cif, '', 0).

           ja = no.
           message skip    " Акцептовать досье?"
                   skip(1)  
                   view-as alert-box button yes-no title " ВНИМАНИЕ ! " update ja.
           if ja then do: 
              for each dsr where dsr.cif = v-cif and dsr.awho = '' and dsr.sts ne 'D':
                  assign dsr.awho = g-ofc dsr.adt = today.
                  find last dsrhis where dsrhis.cif = v-cif  and dsrhis.docs = dsr.docs and dsrhis.rdt = dsr.udt no-error.
                  if avail dsrhis then assign dsrhis.awho = g-ofc dsrhis.adt = today.
              end.
           end.

         end.
    end.
    when 3 then run dsrlist( 3 ).

    when 4 then do:
         /*при акцепте удаленных документов файлы переносятся в архив и физически удаляются из каталога */
         def var v-arcname as char.
         def var v-datetime as char.
         def var v-tim as integer.
         def var v-dsrarc as char init "/data/export/dossier/arc/".
         def var v-result as char.
         v-cif = "".
         v-cifname = "".
       
         def frame f-client1 
           v-cif label "КЛИЕНТ " format "x(6)" colon 10 help " Введите код клиента (F2 - поиск)"
             validate (can-find(first cif where cif.cif = v-cif no-lock), " Клиент с таким кодом не найден!")
           v-cifname no-label format "x(45)" colon 18
           with side-label row 5 no-box.
         
         repeat on endkey undo, return:
              update v-cif with frame f-client1.
            
              find first cif where cif.cif = v-cif no-lock no-error.
              v-cifname = trim((cif.prefix) + " " + trim(cif.name)).
            
              displ v-cifname with frame f-client1.
            
              ja = no.
              message skip    " Акцептовать удаление документов по данному клиенту? "
                      skip(1)  
                      view-as alert-box button yes-no title " ВНИМАНИЕ ! " update ja.
      
      
              if ja then do: 
                  
                 find sysc where sysc.sysc = "DSRARC" no-lock no-error.
                 if avail sysc then v-dsrarc = trim(sysc.chval).
                 if substr(v-dsrarc, length(v-dsrarc), 1) <> "/" then v-dsrarc = v-dsrarc + "/".
                 
                 find first dsr where dsr.cif = v-cif and dsr.awho = '' and dsr.sts = 'D' no-lock no-error.
                     if not avail dsr then do:
                        message skip " У этого клиента нет удаленных документов !!! "  skip(1) 
                              view-as alert-box buttons ok title " ОШИБКА ! ".
                        leave.
                     end.

                 for each dsr where dsr.cif = v-cif and dsr.awho = '' and dsr.sts = 'D':
                    v-datetime = substr(string(year(today),"9999"), 3, 2) + string(month(today), "99") + string(day(today), "99").
                    v-tim = time.
                    v-datetime = v-datetime + entry(1, string(v-tim, "HH:MM:SS"), ":") + entry(2, string(v-tim, "HH:MM:SS"), ":") + entry(3, string(v-tim, "HH:MM:SS"), ":").
                    v-arcname = dsr.docs + '-' + v-cif + entry(1, s-fileext, ".") + "-" + v-datetime + '.' + entry(2, s-fileext, ".").
                    input through value("cp " + s-dsrpath + lc (dsr.docs + '-' + v-cif + s-fileext) + " " + v-dsrarc + lc (v-arcname) + "; echo $?").
                    repeat:
                      import v-result.
                    end.
                    if v-result <> "0" then do:
                      message skip " Произошла ошибка при переносе файла в архив " s-dsrpath + lc (dsr.docs + '-' + v-cif + s-fileext) skip(1) 
                              view-as alert-box buttons ok title " ОШИБКА ! ".
                      
                    end.
                    else do:
                      unix silent value("rm -f " + s-dsrpath + lc (dsr.docs + '-' + v-cif + s-fileext)).
                      assign dsr.awho = g-ofc dsr.adt = today.
                      find last dsrhis where dsrhis.cif = v-cif  and dsrhis.docs = dsr.docs and dsrhis.rdt = dsr.udt and dsrhis.sts = 'D' no-error.
                      if avail dsrhis then assign dsrhis.awho = g-ofc dsrhis.adt = today.
                    end.
                 end.
               end.  
         end.
    end.

  end case.
end.

