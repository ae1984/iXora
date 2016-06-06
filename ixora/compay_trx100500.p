/* compay_trx.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * BASES
        BANK COMM
 * AUTHOR
        24.05.2012 k.gitalov перекомпиляция
 * CHANGES

                    04/09/2012 Luiza  - добавила проствление кассплана для счета jl.gl = 100500
*/


def input param Doc as COMPAYDOCClass.
define input parameter v-arp as character no-undo.
def output param iRez as log init no.

/************************************************************************************/
find first comm.pksysc where comm.pksysc.sysc = "comadm" no-lock no-error.
if avail comm.pksysc then
do:
  if comm.pksysc.loval = no then
  do:
    message "Прием платежей Авангард-Plat в данное время недоступен!" view-as alert-box title "Внимание".
    return.
  end.
end.
else do:
  message "Не найден адрес старшего кассира Авангард-Plat!" view-as alert-box.
  return.
end.
/************************************************************************************/



 if not VALID-OBJECT(Doc)  then do: message "Объект не инициализирован!" view-as alert-box. return. end.

 def var vdel   as char init "^".
 def var vparam as char.
 def var rcode  as int.
 def var rdes   as char.
 def var casvod as log.
 def var v-yn   as log init false.
 def var o-arp  as char. /*Арп счет для работы через кассу в пути */
 def var v-err  as log init false.
 def var jdno as char.
 def new shared var s-jh like jh.jh.

 find sysc where sysc.sysc = 'CASVOD' no-error.
 if avail sysc then
 do:
  casvod = sysc.loval.
 end.
 else do: message "Нет записи CASVOD в таблице sysc!" view-as alert-box. return. end.

do transaction:


   /************************************************************************************************************************************/
   /*Касса не заблокирована */

   vparam =         " " + vdel +
       string(Doc:summ) + vdel +
                    "1" + vdel +
                  v-arp + vdel +
                Doc:arp + vdel +
     "Платежи " + Doc:suppname + vdel +
                    "1" + vdel +
                    "1" + vdel +
                    "9" + vdel +
                    "9" + vdel +
                Doc:knp.
   s-jh = 0.


   run trxgen("JOU0055", vdel, vparam, "jou", "", output rcode, output rdes, input-output s-jh).




    if rcode ne 0 then do: message "Ошибка формирования проводки JOU0025 " + rdes view-as alert-box. leave. end.
    else do:
     Doc:Edit().
     Doc:jh = s-jh.
     if not Doc:Post() then do: message "Ошибка при сохранении номера проводки документа!" view-as alert-box. leave. end.
     else iRez = Yes.

    end.



  /****/


    find jh where jh.jh = s-jh exclusive-lock.
    if avail jh then
    do:
     /* jh.sts = 5.*/
      for each jl where jl.jh = s-jh exclusive-lock:
     /*  jl.sts = 5.*/
       jl.teller = Doc:who_cr.

       /*символ касплана*/
       if jl.gl = 100100 or jl.gl = 100200 or jl.gl = 100500 then
       do:
         create jlsach.
         jlsach.jh = s-jh.
         jlsach.amt = jl.dam + jl.cam.
         jlsach.ln = jl.ln.
         jlsach.lnln = 1.
         jlsach.sim = 100. /*прочие поступления*/
       end.

      end. /*each jl*/

      run jou.

      jdno = return-value.
      if jdno <> "" then
      do:
       find first joudoc where docnum = jdno.
       if avail joudoc then
       do:
        joudoc.info = Doc:payname.
        joudoc.perkod = Doc:payrnn.
        joudoc.comcode = Doc:paycod.
       end.
      end.
      else do:
        message "Ошибка формирования joudoc!" view-as alert-box.
        leave.
      end.

    end.
    else do:
        message "Ошибка формирования проводки!" view-as alert-box.
        leave.
    end.

 end. /*transaction*/