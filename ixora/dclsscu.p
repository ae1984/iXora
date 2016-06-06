/* dclsscu.p
 * MODULE
        Закрытие дня.
 * DESCRIPTION
        Начисления вознаграждения по ЦБ в атоматическом режиме.

	Формуда для ежедневного начисления:
	Сумма закрыт - Сумма открыт / кол-во дней до погашения = >>>>>>>>9.<< (достаточно две цифры после запятой)
	scu.ycam[2]  - scu.ycam[4]  / scu.lonsec 
 * RUN
        dayclose.p
 * CALLER                                  
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        dayclose.p
 * AUTHOR
        2009.08.24 id00024
 * BASES
        BANK
 * CHANGES

*/


/* определение переменных для программы */
def shared var g-today as date format "99/99/9999".
def shared var s-target as date format "99/99/9999".
define new shared stream m-out.

/* определение переменных для расчета */
def var v-paysum as dec.
def var v-paysumround as dec.
def var v-decpnt as integer init 2.
def var v-days as int.

/* определение переменных для trxgrn*/
def var v-jh as int init 0.
def var rcode as int.
def var rdes as char.
def var vdel as char init "|".
def var vparam as char.
def var MESS as char.

output stream m-out to dclsscu.log append.


/* 30 and 40 group only */

    def buffer b-scu for scu.
    for each scu where scu.ddt[1] <= g-today and scu.cdt[1] > g-today  and (scu.grp = 30 or scu.grp = 40) no-lock.
    v-days = s-target - g-today.
    v-paysum = (scu.ycam[3] - scu.ycam[1]) / scu.lonsec * v-days.
    v-paysum = v-paysum + scu.m10.
    v-paysumround = round(v-paysum,v-decpnt).

          run СhargeSCU11(v-paysumround).
          if rcode = 0 then do:
             do transaction:
                find first b-scu where b-scu.scu = scu.scu exclusive-lock no-error.
	            if avail b-scu then do:
                    b-scu.m10 = v-paysum - v-paysumround.
                    find current b-scu no-lock.
                    MESS = string(g-today) + " - " + string(s-target) + "    по счету " + scu.scu + " произведено накопление вознаграждения на 2 уровень. Номер проводки " + string( v-jh ) + ". Сумма " + string( v-paysumround ).
                    end. /* do */
             end. /* transaction */
           end. /* do */
      put stream m-out unformatted MESS skip.
      end. /* for */

      put stream m-out unformatted " " skip.
      output stream m-out close.

/**************************************** Ежедневное накопление % ***********************************/
Procedure СhargeSCU11.

    def input param sum as decimal decimals 2 format "zzz,zzz,zzz,zzz,zzz,zz9.99-".
    vparam = string(sum) + vdel + scu.scu + vdel + scu.scu + vdel + "Ежедневное накопление процентов" + vdel + "" .
    run trxgen("SCU0013", vdel, vparam, "SCU", scu.scu, output rcode, output rdes, input-output v-jh).
    if rcode ne 0 then do:
      MESS = string(g-today) + " - " + string(s-target) + "    не удалось сформировать проводку накопления % для счета " + scu.scu + " в сумме " + string( sum ) + " -> " + rdes + "Проводка номер " + string( v-jh ).
    end.
end procedure.
/*****************************************************************************************************/
