/* londebt.p
 * MODULE
        Кредитные операции
 * DESCRIPTION
        Списание задолженности
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        3-1-1
 * AUTHOR
        20/09/2011 kapar
 * BASES
        BANK COMM
 * CHANGES
        29/05/2013 Sayat(id01143) - отключены проводки по 3-му классу (уровни 38,39 и 40) ТЗ 1860 от 28/05/2013
        26/08/2013 galina - ТЗ1231 списываем в доходы излишки провизий по ОД, %% и штрафам
*/

{global.i}

def shared var s-lon like lon.lon.
def new shared  var s-jh like jh.jh .

def var v-lcnt  as char no-undo initial " ".

def var v-sum    as decimal.
def var v-sum1   as decimal.
def var v-sum2   as decimal.
def var v-sum6  as decimal.
def var v-sum38  as decimal.
def var v-sum39  as decimal.
def var v-sum40  as decimal.
def var v-sum41  as decimal.
def var v-date   as date.
v-date = g-today.

def var vparam as char no-undo.
def var rcode  as int no-undo.
def var rdes   as char no-undo.
def var vdel   as char no-undo initial "^".
def var v-rem  as char no-undo.
def var v-tmpl as char no-undo.
def var v-gl   as integer no-undo.


def var d-rate as date.
def var v-rate as decimal.

def var v-bal6    as decimal.
def var v-bal36    as decimal.
def var v-bal37  as decimal.

message "Произвести списание займа? " view-as alert-box QUESTION BUTTONS YES-NO UPDATE B AS LOGICAL.
if B = true then do transaction on error undo, return:
  find first lon where lon.lon = s-lon no-lock no-error.
  if avail lon then
  do:

     find first cif where cif.cif = lon.cif no-lock no-error.
     if not avail cif then do:
         message " Не найдена клиентская запись! ".
         return.
     end.

     find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = lon.cif and sub-cod.d-cod = "clnsts" no-lock no-error.
     if sub-cod.ccode <> "0" and sub-cod.ccode <> "1" then do:
       message "У клиента не проставлен корректный признак физ./юр. лицо!".
       return.
     end.

     run lonbalcrc('lon',lon.lon,v-date,"1",yes,lon.crc,output v-sum1).
     run lonbalcrc('lon',lon.lon,v-date,"2",yes,lon.crc,output v-sum2).
     if (v-sum1 <> 0) or (v-sum2 <> 0) then do:
       message "Не все суммы по ОД и по процентам просрочены".
       return.
     end.

     d-rate = date('01/' + string(month(v-date)) + '/' + string(year(v-date))).
     find last crchis where crchis.crc = lon.crc and crchis.rdt < d-rate no-lock no-error.
     if avail crchis then v-rate = crchis.rate[1].

     message "kurs data =" + string(d-rate).
     pause.
     message "kurs=" + string(v-rate).
     pause.

     find loncon where loncon.lon = lon.lon no-lock no-error.
     if avail loncon then v-lcnt = loncon.lcnt.

     /*--------------По резервам МСФО по балансовому счету 1428---------------------------------------------------------------------------*/
     run lonbalcrc('lon',lon.lon,v-date,"6",yes,lon.crc,output v-sum1).
     run lonbalcrc('lon',lon.lon,v-date,"7",yes,lon.crc,output v-sum2).
     v-sum = v-sum2 + v-sum1.
     v-sum6 = v-sum.
     message "7-6=" + string(v-sum).
     pause.
     if (v-sum > 0) then do:
         v-rem = "Формирование провизий по МСФО в связи со списанием за баланс займам по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0161".
         if (lon.prnmos = 2) or (lon.prnmos = 3) then v-gl = 545500.
         if (lon.prnmos = 1) then v-gl = 545510.
         vparam = string(v-sum) + vdel + string(lon.crc) + vdel +
                  string(v-gl) + vdel +
                  '6' + vdel +
                  lon.lon + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message1:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
         /*then do transaction:*/
           /*hide all.*/
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
            /* sts ne 6 */
           {x-jlvf.i}
         /*end.*/
     end.

     run lonbalcrc('lon',lon.lon,v-date,"36",yes,lon.crc,output v-sum1).
     run lonbalcrc('lon',lon.lon,v-date,"9",yes,lon.crc,output v-sum2).
     v-sum = v-sum2 + v-sum1  .
     v-sum39 = - v-sum.
     message "9-36=" + string(v-sum).
     pause.
     if (v-sum > 0) then do:
         v-rem = "Формирование провизий по МСФО в связи со списанием за баланс займам по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0161".
         vparam = string(v-sum) + vdel + string(lon.crc) + vdel +
                  '545520' + vdel +
                  '36' + vdel +
                  lon.lon + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message2:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
         /*then do transaction:*/
           /*hide all.*/
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
            /* sts ne 6 */
           {x-jlvf.i}
         /*end.*/
     end.

     run lonbalcrc('lon',lon.lon,v-date,"37",yes,1,output v-sum1).
     run lonbalcrc('lon',lon.lon,v-date,"16",yes,1,output v-sum2).
     v-sum = v-sum2 + v-sum1.
     v-sum40 = - v-sum.
     message "16-37=" + string(v-sum).
     pause.
     if (v-sum > 0) then do:
         v-rem = "Формирование провизий по МСФО в связи со списанием за баланс займам по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0161".
         vparam = string(v-sum) + vdel + '1' + vdel +
                  '545530' + vdel +
                  '37' + vdel +
                  lon.lon + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message3:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
         /*then do transaction:*/
           /*hide all.*/
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
            /* sts ne 6 */
           {x-jlvf.i}
         /*end.*/
     end.

     /*--------------По резервам АФН по счету 9100---------------------------------------------------------------------------*/
     run lonbalcrc('lon',lon.lon,v-date,"41",yes,lon.crc,output v-sum1).
     run lonbalcrc('lon',lon.lon,v-date,"7",yes,lon.crc,output v-sum2).
     v-sum = v-sum1 + v-sum2.
     v-sum41 = v-sum.
     message "41-7=" + string(v-sum).
     pause.
     if (v-sum > 0) then do:
         v-rem = "Формирование провизий по правилам АФН в связи со списанием за баланс займа по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0161".
         vparam = string(v-sum) + vdel + string(lon.crc) + vdel +
                  '950000' + vdel +
                  '41' + vdel +
                  lon.lon + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message4:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
         /*then do transaction:*/
           /*hide all.*/
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
            /* sts ne 6 */
           {x-jlvf.i}
         /*end.*/
     end.

     /*--------------По изменению разницы между АФН и МСФО по счету 3305---------------------------------------------------------------------------*/
     /*
     v-sum38 = (v-sum41 - v-sum6) * v-rate.
     message "38<" + string(v-sum38).
     pause.
     if (v-sum38 < 0) then do:
         v-sum = - v-sum38.
         v-rem = "Корректировка разницы между суммами провизий по МСФО и АФН в связи со списанием за баланс займа по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0162".
         vparam = string(v-sum) + vdel + '1' + vdel +
                  '38' + vdel +
                  lon.lon + vdel +
                  '359913' + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message5:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
           hide all.
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
           {x-jlvf.i}
     end.

     v-sum39 = v-sum39 * v-rate.
     message "39<" + string(v-sum39).
     pause.
     if (v-sum39 < 0) then do:
         v-sum = - v-sum39.
         v-rem = "Корректировка разницы между суммами провизий по МСФО и АФН в связи со списанием за баланс займа по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0162".
         vparam = string(v-sum) + vdel + '1' + vdel +
                  '39' + vdel +
                  lon.lon + vdel +
                  '359913' + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message5:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
           hide all.
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
           {x-jlvf.i}
     end.

     v-sum40 = v-sum40.
     message "40<" + string(v-sum40).
     pause.
     if (v-sum40 < 0) then do:
         v-sum = - v-sum40.
         v-rem = "Корректировка разницы между суммами провизий по МСФО и АФН в связи со списанием за баланс займа по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0162".
         vparam = string(v-sum) + vdel + '1' + vdel +
                  '39' + vdel +
                  lon.lon + vdel +
                  '359913' + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message5:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
           hide all.
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
           {x-jlvf.i}
     end.

     message "38>" + string(v-sum38).
     pause.
     if (v-sum38 > 0) then do:
         v-sum = v-sum38.
         v-rem = "Корректировка разницы между суммами провизий по МСФО и АФН в связи со списанием за баланс по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0161".
         vparam = string(v-sum) + vdel + '1' + vdel +
                  '359913' + vdel +
                  '38' + vdel +
                  lon.lon + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message6:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
           hide all.
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
           {x-jlvf.i}
     end.

     message "39>" + string(v-sum39).
     pause.
     if (v-sum39 > 0) then do:
         v-sum = v-sum39.
         v-rem = "Корректировка разницы между суммами провизий по МСФО и АФН в связи со списанием за баланс по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0161".
         vparam = string(v-sum) + vdel + '1' + vdel +
                  '359913' + vdel +
                  '39' + vdel +
                  lon.lon + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message6:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
           hide all.
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
           {x-jlvf.i}
     end.

     message "40>" + string(v-sum40).
     pause.
     if (v-sum40 > 0) then do:
         v-sum = v-sum40.
         v-rem = "Корректировка разницы между суммами провизий по МСФО и АФН в связи со списанием за баланс по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0161".
         vparam = string(v-sum) + vdel + '1' + vdel +
                  '359913' + vdel +
                  '39' + vdel +
                  lon.lon + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message6:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
           hide all.
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
           {x-jlvf.i}
     end.
     */
     /*--------------По списанию просроченного ОД, вознаграждения и штрафов за счет сформированного резерва МСФО---------------------------------------------------------------------------*/
     run lonbalcrc('lon',lon.lon,v-date,"7",yes,lon.crc,output v-sum).
     message "7=" + string(v-sum).
     pause.
     if (v-sum <> 0) then do:
         v-rem = "Списание за баланс займа (проср. ОД) по решению КК кредитного договора № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0160".
         vparam = string(v-sum) + vdel + string(lon.crc) + vdel +
                  '6' + vdel +
                  lon.lon + vdel +
                  '7' + vdel +
                  lon.lon + vdel +
                  v-rem + vdel +

                  string(v-sum) + vdel + string(lon.crc) + vdel +
                  '13' + vdel +
                  lon.lon + vdel +
                  '813000' + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message1:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
         /*then do transaction:*/
           /*hide all.*/
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
            /* sts ne 6 */
           {x-jlvf.i}
         /*end.*/
     end.

     run lonbalcrc('lon',lon.lon,v-date,"9",yes,lon.crc,output v-sum).
     message "9=" + string(v-sum).
     pause.
     if (v-sum <> 0) then do:
         v-rem = "Списание за баланс займа (проср. ОД) по решению КК кредитного договора № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0160".
         vparam = string(v-sum) + vdel + string(lon.crc) + vdel +
                  '36' + vdel +
                  lon.lon + vdel +
                  '9' + vdel +
                  lon.lon + vdel +
                  v-rem + vdel +

                  string(v-sum) + vdel + string(lon.crc) + vdel +
                  '14' + vdel +
                  lon.lon + vdel +
                  '813000' + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message2:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
         /*then do transaction:*/
           /*hide all.*/
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
            /* sts ne 6 */
           {x-jlvf.i}
         /*end.*/
     end.

     run lonbalcrc('lon',lon.lon,v-date,"16",yes,1,output v-sum).
     message "16=" + string(v-sum).
     pause.
     if (v-sum <> 0) then do:
         v-rem = "Списание за баланс займа (проср. ОД) по решению КК кредитного договора № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0160".
         vparam = string(v-sum) + vdel + '1' + vdel +
                  '37' + vdel +
                  lon.lon + vdel +
                  '16' + vdel +
                  lon.lon + vdel +
                  v-rem + vdel +

                  string(v-sum) + vdel + '1' + vdel +
                  '30' + vdel +
                  lon.lon + vdel +
                  '813000' + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message2:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
         /*then do transaction:*/
           /*hide all.*/
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
            /* sts ne 6 */
           {x-jlvf.i}
         /*end.*/
     end.

     /*--------------По списанию резерва АФН (счет 9100) в связи со списанием за баланс займа---------------------------------------------------------------------------*/

     run lonbalcrc('lon',lon.lon,v-date,"41",yes,lon.crc,output v-sum).
     v-sum = - v-sum.
     message "41=" + string(v-sum).
     pause.
     if (v-sum > 0) then do:
         v-rem = "В связи со списанием за баланс займа по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0162".
         vparam = string(v-sum) + vdel + string(lon.crc) + vdel +
                  '41' + vdel +
                  lon.lon + vdel +
                  '950000' + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message6:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
         /*then do transaction:*/
           /*hide all.*/
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
            /* sts ne 6 */
           {x-jlvf.i}
         /*end.*/
     end.
     /*-------------Списываем излишки провизий на доходы---------*/

     run lonbalcrc('lon',lon.lon,v-date,"6",yes,lon.crc,output v-bal6).
     run lonbalcrc('lon',lon.lon,v-date,"36",yes,lon.crc,output v-bal36).
     run lonbalcrc('lon',lon.lon,v-date,"37",yes,lon.crc,output v-bal37).
     if v-bal6 <> 0 or v-bal36 <> 0 or v-bal37 <> 0 then assign v-rem = "В связи со списанием за баланс займа, Кредитный договор № " + v-lcnt + " от " + string(lon.rdt,'99/99/9999') + ", " + cif.name.
                                                                v-tmpl = "LON0150".

     if v-bal6 <> 0 then do:
         vparam = string(abs(v-bal6)) + vdel + string(lon.crc) + vdel +
                  '6' + vdel + lon.lon + vdel + string(495500) + vdel + v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message7:" rcode rdes.
             pause.
         end.

         run lonresadd(s-jh).
         message "Провизии по ОД списаны. Номер проводки " + string(s-jh).
         pause.
         run x-jlvou.

     end.
     if v-bal36 <> 0 then do:
         vparam = string(abs(v-bal36)) + vdel + string(lon.crc) + vdel +
                  '36' + vdel + lon.lon + vdel + string(495520) + vdel + v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message8:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).
         message "Провизии по %% списаны. Номер проводки " + string(s-jh).
         pause.
         run x-jlvou.


     end.
     if v-bal37 <> 0 then do:
         vparam = string(abs(v-bal37)) + vdel + string(lon.crc) + vdel +
                  '37' + vdel + lon.lon + vdel + string(495530) + vdel + v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message9:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).
         message "Провизии по шрафам списаны. Номер проводки " + string(s-jh).
         pause.
         run x-jlvou.

     end.


     /*----------------------------------------------------------*/

     /*---------------По списанию разницы резервов АФН и МСФО (счет 3305) в связи со списанием за баланс займа---------------------------------------------------------------------------*/
     /*
     run lonbalcrc('lon',lon.lon,v-date,"39",yes,1,output v-sum).
     message "39=" + string(v-sum).
     pause.
     if (v-sum > 0) then do:
         v-rem = "В связи со списанием за баланс займа по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0161".
         vparam = string(v-sum) + vdel + '1' + vdel +
                  '359913' + vdel +
                  '39' + vdel +
                  lon.lon + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message5:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
           hide all.
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
           {x-jlvf.i}
     end.

     run lonbalcrc('lon',lon.lon,v-date,"40",yes,1,output v-sum).
     message "40=" + string(v-sum).
     pause.
     if (v-sum > 0) then do:
         v-rem = "В связи со списанием за баланс займа по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0161".
         vparam = string(v-sum) + vdel + '1' + vdel +
                  '359913' + vdel +
                  '40' + vdel +
                  lon.lon + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message5:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
           hide all.
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
           {x-jlvf.i}
     end.
     */


     /*--------------По изменению разницы между АФН и МСФО по счету 3305(дополнительные коректировки разница между суммами)---------------------------------------------------------------------------*/
     /*
     run lonbalcrc('lon',lon.lon,v-date,"38",yes,1,output v-sum38).
     message "38<" + string(v-sum38).
     pause.
     if (v-sum38 < 0) then do:
         v-sum = - v-sum38.
         v-rem = "Корректировка разницы между суммами провизий по МСФО и АФН в связи со списанием за баланс займа по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0162".
         vparam = string(v-sum) + vdel + '1' + vdel +
                  '38' + vdel +
                  lon.lon + vdel +
                  '359913' + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message5:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
           hide all.
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
           {x-jlvf.i}
     end.

     run lonbalcrc('lon',lon.lon,v-date,"39",yes,1,output v-sum39).
     message "39<" + string(v-sum39).
     pause.
     if (v-sum39 < 0) then do:
         v-sum = - v-sum39.
         v-rem = "Корректировка разницы между суммами провизий по МСФО и АФН в связи со списанием за баланс займа по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0162".
         vparam = string(v-sum) + vdel + '1' + vdel +
                  '39' + vdel +
                  lon.lon + vdel +
                  '359913' + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message5:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
           hide all.
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
           {x-jlvf.i}
     end.

     message "38>" + string(v-sum38).
     pause.
     if (v-sum38 > 0) then do:
         v-sum = v-sum38.
         v-rem = "Корректировка разницы между суммами провизий по МСФО и АФН в связи со списанием за баланс по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0161".
         vparam = string(v-sum) + vdel + '1' + vdel +
                  '359913' + vdel +
                  '38' + vdel +
                  lon.lon + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message6:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
           hide all.
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
           {x-jlvf.i}
     end.

     message "39>" + string(v-sum39).
     pause.
     if (v-sum39 > 0) then do:
         v-sum = v-sum39.
         v-rem = "Корректировка разницы между суммами провизий по МСФО и АФН в связи со списанием за баланс по решению КК по кредитному договору № " + v-lcnt + " " + cif.NAME.
         v-tmpl = "LON0161".
         vparam = string(v-sum) + vdel + '1' + vdel +
                  '359913' + vdel +
                  '39' + vdel +
                  lon.lon + vdel +
                  v-rem.
         s-jh = 0.
         run trxgen(v-tmpl, vdel, vparam, "lon", "", output rcode, output rdes, input-output s-jh).
         if rcode <> 0 then do:
             run savelog("londebtlog", "ERROR " + lon.cif + " " + lon.lon + " trx1 " + rdes + " " + vparam).
             message "Message6:" rcode rdes.
             pause.
         end.
         run lonresadd(s-jh).

         find jh where jh.jh eq s-jh.
         find first jl where jl.jh eq s-jh no-lock no-error.
           hide all.
           run x-jlvou.

           if jh.sts ne 6 then do :
              for each jl of jh :
                  jl.sts = 5.
              end.
              jh.sts = 5.
            end.
           {x-jlvf.i}
     end.
     */


  end.
end.
