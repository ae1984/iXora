/* h-ibevnt.p
 * MODULE
        Отчет СВК
 * DESCRIPTION
       Виды событий в истории Internet Office
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
        10.08.2004 tsoy
 * CHANGES
*/

{global.i}

def var h as int init 12.
def var i as int .
def var j as int .

define temp-table tmp
            field id     as char
            field name   as char
            index idx_tmp is primary id. 


do i = 1 to 4:
   do j = 1 to 30:

      find supp where supp.type = 1 and supp.sub_id = 1000 + i * 100 + j no-lock no-error.
      
      if avail supp then do:
           create tmp. 
              tmp.id    =  string (i) + string(j).
              tmp.name  =  supp.vcha[3].
      end.

   end.
end.


do:
{itemlist.i 
        &file = "tmp"
        &start = " "
        &where = " 1 = 1 "
        &form  = "tmp.id tmp.name  "
        &frame = "row 5 centered scroll 1 h down overlay "
        &flddisp = " tmp.id  format ""x(4)"" label ""KOD"" tmp.name format ""x(60)"" label ""NAME"" "
        &chkey = "id"
        &chtype = "string"
        &index  = "idx_tmp"
        &funadd = "if frame-value = """" then do:
                     {imesg.i 9205}.
                     pause 1.
                     next.
                   end." }
end.

return frame-value.
