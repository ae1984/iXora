/* pk_close.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Закрытие текущих счетов, если соответствующие кредиты погашены
 * RUN
      
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-12-9
 * BASES
        BANK COMM
 * AUTHOR
        05.07.2005 marinav
 * CHANGES
        23/09/2005 madiyar - добавил кусочек, отсеивающий счета, привязанные к еще действующим кредитам (не БД)
        10/10/2005 madiyar - по служебке от 10/10/2005 поменял счет ГК с 492120 на 460712
        25/01/2006 madiyar - небольшие изменения в связи с добавлением линии в шаблон lon0058
        03/04/2006 madiyar - по служебке от 31/03/2006 минимальная сумма увеличена с 785 тенге до 1200
        04/04/2006 madiyar - вернули обратно 785 тенге
        19/07/2006 madiyar - исключил тек.счет скандальной клиентки - закрываться не должен
        15/09/2006 madiyar - скандальная клиентка закрыла кредит - убрал проверку
        18/02/2009 madiyar - теперь по валютным экспресс-кредитам автоматически закрываются и тенговые счета
        20/05/2009 galina - добавила автоматическое закрытие 20-тизначных счетов, соотвествующих 9-тизначным
                            выводим в отчет для сведения счета с отстатком более 785 тенге
        26.08.2009 galina - убрала необходимость нажимать пробел в конце программы        
        08/02/2010 galina - выводим сумму комиссионного долга             
        08/04/2010 id00024 - по служебке N 638 от 08/04/2010 минимальная сумма увеличена с 785 тенге до 1000
*/

{global.i}
def stream st1.
def var res   as deci.
def var v-log as logi.
define variable vparam  as character.
define variable vdel    as character initial "^".
define variable rcode   as integer.
define variable rdes    as character.
def new shared var s-jh like jh.jh.
def buffer b-aaa for aaa.
def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def var i as integer no-undo.
def var grps as integer no-undo extent 2.
grps[1] = 90.
grps[2] = 92.

def var v-rate as deci no-undo.
def var v-bal_com  as deci no-undo.
def var v-bal_com20  as deci no-undo.


def temp-table t1
  field fio  as char
  field cif as char
  field aaa as char
  field crcaaa as integer
  field lon as char
  field crclon as integer
  field amount as deci
  field comamt as deci
  index fio amount fio.

def temp-table t2
  field fio  as char
  field cif as char
  field aaa as char
  field crcaaa as integer
  field lon as char
  field crclon as integer
  field amount as deci
  field comamt as deci
  index fio amount fio.  
def buffer b-t1 for t1.
def buffer b-t2 for t2.
        
    do i = 1 to 2:
       for each lon where (lon.grp) = grps[i] no-lock:
          run lonbal('lon', lon.lon, g-today, '1,2,7,9,16,13,14,30', yes, output res).
          if res = 0 then do:
             find first cif where cif.cif = lon.cif no-lock no-error.
             if not avail cif then next.             
             if lon.crc = 1 then v-rate = 1. else do:
                find first crc where crc.crc = lon.crc no-lock no-error.
                v-rate = crc.rate[1].
             end.
             find first aaa where aaa.aaa = lon.aaa no-lock no-error.
             if avail aaa and aaa.sta ne 'C' then do:
               v-bal_com = 0.
               for each bxcif where bxcif.cif = lon.cif and bxcif.type = "195" and bxcif.aaa = lon.aaa no-lock:
                 v-bal_com = v-bal_com + bxcif.amount.
               end.

               find first b-aaa where b-aaa.aaa = aaa.aaa20 no-lock no-error.
               if not avail b-aaa then do:
                   if aaa.cr[1] - aaa.dr[1] <= round(1000 / v-rate,2) then do:
                        create t1.
                        assign t1.fio = cif.name
                               t1.cif = cif.cif
                               t1.aaa = aaa.aaa
                               t1.crcaaa = aaa.crc
                               t1.lon = lon.lon
                               t1.crclon = lon.crc
                               t1.amount = aaa.cr[1] - aaa.dr[1]
                               t1.comamt = v-bal_com.
                   end.
                   else do:
                        create t2.
                        assign t2.fio = cif.name
                               t2.cif = cif.cif
                               t2.aaa = aaa.aaa
                               t2.crcaaa = aaa.crc
                               t2.lon = lon.lon
                               t2.crclon = lon.crc
                               t2.amount = aaa.cr[1] - aaa.dr[1]
                               t2.comamt = v-bal_com.
                   end.    
               end. 
               else do:
                   v-bal_com20 = 0.
                   for each bxcif where bxcif.cif = lon.cif and bxcif.type = "195" and bxcif.aaa = b-aaa.aaa no-lock:
                     v-bal_com20 = v-bal_com20 + bxcif.amount.
                   end.

                   if (aaa.cr[1] - aaa.dr[1] <= round(1000 / v-rate,2)) and (b-aaa.cr[1] - b-aaa.dr[1] <= round(1000 / v-rate,2)) then do:
                   
                        create t1.
                        assign t1.fio = cif.name
                               t1.cif = cif.cif
                               t1.aaa = aaa.aaa
                               t1.crcaaa = aaa.crc
                               t1.lon = lon.lon
                               t1.crclon = lon.crc
                               t1.amount = aaa.cr[1] - aaa.dr[1]
                               t1.comamt = v-bal_com.

                        create t1.
                        assign t1.fio = cif.name
                               t1.cif = cif.cif
                               t1.aaa = b-aaa.aaa
                               t1.crcaaa = b-aaa.crc
                               t1.lon = lon.lon
                               t1.crclon = lon.crc
                               t1.amount = b-aaa.cr[1] - b-aaa.dr[1]
                               t1.comamt = v-bal_com20.

                   end.
                   if (aaa.cr[1] - aaa.dr[1] > round(1000 / v-rate,2)) or (b-aaa.cr[1] - b-aaa.dr[1] > round(1000 / v-rate,2)) then do:
                        create t2.
                        assign t2.fio = cif.name
                               t2.cif = cif.cif
                               t2.aaa = aaa.aaa
                               t2.crcaaa = aaa.crc
                               t2.lon = lon.lon
                               t2.crclon = lon.crc
                               t2.amount = aaa.cr[1] - aaa.dr[1]
                               t2.comamt = v-bal_com.

                        create t2.
                        assign t2.fio = cif.name
                               t2.cif = cif.cif
                               t2.aaa = b-aaa.aaa
                               t2.crcaaa = b-aaa.crc
                               t2.lon = lon.lon
                               t2.crclon = lon.crc
                               t2.amount = b-aaa.cr[1] - b-aaa.dr[1]
                               t2.comamt = v-bal_com20.
                   end.
               end.       
             end.
             /* по валютным кредитам - найдем еще и связанные с ними тенговые счета */
             if lon.crc <> 1 then do:
                 find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = lon.lon no-lock no-error.
                 if avail pkanketa then do:
                    find first aaa where aaa.aaa = pkanketa.aaa no-lock no-error.
                    if avail aaa and aaa.sta ne 'C'then do:

                       v-bal_com = 0.
                       for each bxcif where bxcif.cif = lon.cif and bxcif.type = "195" and bxcif.aaa = lon.aaa no-lock:
                          v-bal_com = v-bal_com + bxcif.amount.
                       end.
                       find first b-aaa where b-aaa.aaa = aaa.aaa20 no-lock no-error.
                       if not avail b-aaa then do:
                       
                           if aaa.cr[1] - aaa.dr[1] <= 1000 then do:
                               create t1.
                               assign t1.fio = cif.name
                                      t1.cif = cif.cif
                                      t1.aaa = aaa.aaa
                                      t1.crcaaa = aaa.crc
                                      t1.lon = lon.lon
                                      t1.crclon = lon.crc
                                      t1.amount = aaa.cr[1] - aaa.dr[1]
                                      t1.comamt = v-bal_com.
                           end.           
                           else do:
                                create t2.
                                assign t2.fio = cif.name
                                       t2.cif = cif.cif
                                       t2.aaa = aaa.aaa
                                       t2.crcaaa = aaa.crc
                                       t2.lon = lon.lon
                                       t2.crclon = lon.crc
                                       t2.amount = aaa.cr[1] - aaa.dr[1]
                                       t2.comamt = v-bal_com.
                           end.
                       end.    
                       else do:
                           v-bal_com20 = 0.
                           for each bxcif where bxcif.cif = lon.cif and bxcif.type = "195" and bxcif.aaa = b-aaa.aaa no-lock:
                             v-bal_com20 = v-bal_com20 + bxcif.amount.
                           end.                       
                           if (aaa.cr[1] - aaa.dr[1] <= 1000) and (b-aaa.cr[1] - b-aaa.dr[1] <= 1000) then do:
                               create t1.
                               assign t1.fio = cif.name
                                      t1.cif = cif.cif
                                      t1.aaa = aaa.aaa
                                      t1.crcaaa = aaa.crc
                                      t1.lon = lon.lon
                                      t1.crclon = lon.crc
                                      t1.amount = aaa.cr[1] - aaa.dr[1]
                                      t1.comamt = v-bal_com.
                              
                               create t1.
                               assign t1.fio = cif.name
                                      t1.cif = cif.cif
                                      t1.aaa = b-aaa.aaa
                                      t1.crcaaa = b-aaa.crc
                                      t1.lon = lon.lon
                                      t1.crclon = lon.crc
                                      t1.amount = b-aaa.cr[1] - b-aaa.dr[1]
                                      t1.comamt = v-bal_com20.
                                      
                           end. 
                           if (aaa.cr[1] - aaa.dr[1] > 1000) or (b-aaa.cr[1] - b-aaa.dr[1] > 1000) then do:
                               create t2.
                               assign t2.fio = cif.name
                                      t2.cif = cif.cif
                                      t2.aaa = aaa.aaa
                                      t2.crcaaa = aaa.crc
                                      t2.lon = lon.lon
                                      t2.crclon = lon.crc
                                      t2.amount = aaa.cr[1] - aaa.dr[1]
                                      t2.comamt = v-bal_com.
                              
                               create t2.
                               assign t2.fio = cif.name
                                      t2.cif = cif.cif
                                      t2.aaa = b-aaa.aaa
                                      t2.crcaaa = b-aaa.crc
                                      t2.lon = lon.lon
                                      t2.crclon = lon.crc
                                      t2.amount = b-aaa.cr[1] - b-aaa.dr[1]
                                      t2.comamt = v-bal_com20.
                                      
                           end. 
                                                                                   
                       end.
                    end.   
                 end.
             end. /* if lon.crc <> 1 */
          end.
       end.
   end. /* do i = 1 to 2 */
   
   for each t1:
     for each lon where lon.cif = t1.cif no-lock:
       if lon.grp = 90 or lon.grp = 92 or lon.aaa <> t1.aaa then next.
       run lonbal('lon', lon.lon, g-today, '1,2,7,9,16,13,14,30', yes, output res).
       if res > 0 then do:
         find first aaa where aaa.aaa = t1.aaa no-lock.
         if avail aaa and aaa.aaa20 <> '' then do:
           find first b-t1 where b-t1.aaa = aaa.aaa20.
           delete b-t1.
         end. 
         delete t1.
         leave.
       end.
     end.
   end.

   for each t2:
     for each lon where lon.cif = t2.cif no-lock:
       if lon.grp = 90 or lon.grp = 92 or lon.aaa <> t2.aaa then next.
       run lonbal('lon', lon.lon, g-today, '1,2,7,9,16,13,14,30', yes, output res).
       if res > 0 then do:
         find first aaa where aaa.aaa = t2.aaa no-lock.
         if avail aaa and aaa.aaa20 <> '' then do:
           find first b-t2 where b-t2.aaa = aaa.aaa20.
           delete b-t2.
         end. 
         delete t2.
         leave.
       end.
     end.
   end.
   
  output stream st1 to acc.img.

{html-title.i 
    &stream = " stream st1 "
    &title = " "
    &size-add = "x-"
   }
   put stream st1 unformatted   "<P align=""center"" style=""font:bold"">Текущие счета по погашенным беззалоговым кредитам для закрытия"  skip.

   put stream st1 unformatted
     "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
       "<TR align=""center"" style=""font:bold"">" skip
         "<TD>ФИО</TD>" skip
         "<TD>Код</TD>" skip
         "<TD>Кредит</TD>" skip
         "<TD>Вал. кредита</TD>" skip
         "<TD>Текущий счет</TD>" skip
         "<TD>Вал. тек. счета</TD>" skip
         "<TD>Сумма на счете</TD>" skip
         "<TD>Комиссионный долг</TD>"
     "</TR>" skip.
   
   for each t1 break by t1.cif.
        put stream st1 unformatted
           "<TR>"
             "<TD>" t1.fio format "x(30)" "</TD>" skip
             "<TD align=""center"">" t1.cif format "x(8)" "</TD>" skip
             "<TD align=""center"">`" t1.lon format "x(10)" "</TD>" skip
             "<TD align=""center"">" t1.crclon "</TD>" skip
             "<TD align=""center"">`" t1.aaa format "x(21)" "</TD>" skip
             "<TD align=""center"">" t1.crcaaa "</TD>" skip
             "<TD align=""center"">" replace(trim(string(t1.amount, "->>>>>>>>>>>9.99")),".",",")  "</TD>" skip
             "<TD align=""center"">" replace(trim(string(t1.comamt, "->>>>>>>>>>>9.99")),".",",")  "</TD>" skip
           "</TR>" skip.
   end.
    put stream st1 unformatted "</TABLE>" skip(2).

/**/
   put stream st1 unformatted   "<P align=""center"" style=""font:bold"">Текущие счета по погашенным беззалоговым кредитам для закрытия с суммой более 1000 тенге <br>(автоматически не закрываются)"  skip.

   put stream st1 unformatted
     "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
       "<TR align=""center"" style=""font:bold"">" skip
         "<TD>ФИО</TD>" skip
         "<TD>Код</TD>" skip
         "<TD>Кредит</TD>" skip
         "<TD>Вал. кредита</TD>" skip
         "<TD>Текущий счет</TD>" skip
         "<TD>Вал. тек. счета</TD>" skip
         "<TD>Сумма на счете</TD>" skip
         "<TD>Комиссионный долг</TD>"
     "</TR>" skip.
   
   for each t2 break by t2.cif.
        put stream st1 unformatted
           "<TR>"
             "<TD>" t2.fio format "x(30)" "</TD>" skip
             "<TD align=""center"">" t2.cif format "x(8)" "</TD>" skip
             "<TD align=""center"">`" t2.lon format "x(10)" "</TD>" skip
             "<TD align=""center"">" t2.crclon "</TD>" skip
             "<TD align=""center"">`" t2.aaa format "x(21)" "</TD>" skip
             "<TD align=""center"">" t2.crcaaa "</TD>" skip
             "<TD align=""center"">" replace(trim(string(t2.amount, "->>>>>>>>>>>9.99")),".",",")  "</TD>" skip
             "<TD align=""center"">" replace(trim(string(t2.comamt, "->>>>>>>>>>>9.99")),".",",")  "</TD>" skip
           "</TR>" skip.
   end.
   put stream st1 unformatted "</TABLE>" skip.
/**/

   {html-end.i " stream st1 "}
 
   output stream st1 close.
   unix silent cptwin acc.img excel.
   find first t1 no-lock no-error.
   if not avail t1 then return.
    message skip    " Закрыть счета из первой таблицы?"
            skip(1)
            view-as alert-box button yes-no title " ВНИМАНИЕ ! " update yesno as logi.

    if yesno then do:

    message ' Идет закрытие счетов ...'.
    for each t1.

       find first aaa where aaa.aaa = t1.aaa exclusive-lock no-error.
       if avail aaa then do:

           if t1.amount > 0 then do:
        
              vparam = string (t1.amount) + vdel +
                       string (t1.aaa) + vdel +
                       string('460712') + vdel +
                       "Перенос в связи с досрочным погашением кредита " + vdel +
                       " " + vdel +
                       '840' .
              s-jh = 0.
              run trxgen ("LON0059", vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).
            
              if rcode <> 0 then do: message rcode rdes. pause 100. return. end.
           end.
            
           find sub-cod where sub = 'cif' and sub-cod.acc = t1.aaa and sub-cod.d-cod = 'clsa' no-lock no-error.
            
           if not avail sub-cod then do:
                create sub-cod.
                sub-cod.sub = 'cif'.
                sub-cod.acc = t1.aaa.
                sub-cod.d-cod = 'clsa'.
                sub-cod.ccode = '02'.
                sub-cod.rdt = today.
            end.
            aaa.sta = 'C'.
            release aaa.
       end.
    end.
    hide message no-pause.
    end.
    
