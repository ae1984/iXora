/* mt100.i
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/


def {1} shared var v-sender as char.
def {1} shared var v-snddate as char.
						/* 20 */

def {1} shared var v-ref like rem.ref.
						/* 32A */
def {1} shared var v-F32 as char.
def {1} shared var v-valdt like rem.valdt.
def {1} shared var v-crccode like crc.code.
def {1} shared var v-payment like rem.payment.
						/* 50 */

def {1} shared var v-ordcst like rem.ordcst.
						/* 52 */
def {1} shared var v-F52 as char.
def {1} shared var v-DC52 as char.
def {1} shared var v-ordinsact like rem.ordinsact.
def {1} shared var v-ordins like rem.ordins.
						/* 53 */
def {1} shared var v-F53 as char.
def {1} shared var v-DC53 as char.
def {1} shared var v-sndcoract like rem.sndcoract.
def {1} shared var v-sndcor like rem.sndcor.
						       /* 54 */
def {1} shared var v-F54 as char.
def {1} shared var v-DC54 as char.
def {1} shared var v-rcvcoract like rem.rcvcoract.
def {1} shared var v-rcvcor like rem.rcvcor.

						/* 56 */
def {1} shared var v-F56 as char.
def {1} shared var v-DC56 as char.
def {1} shared var v-intmedact like rem.intmedact.
def {1} shared var v-intmed like rem.intmed.

						/* 57 */
def {1} shared var v-F57 as char.
def {1} shared var v-DC57 as char.
def {1} shared var v-actinsact like rem.actinsact.
def {1} shared var v-actins like rem.actins.

						/* 59 */
def {1} shared var v-DC59 as char.
def {1} shared var v-ba like rem.ba.
def {1} shared var v-ben like rem.ben.

						/* 70 */
def {1} shared var v-detpay like rem.detpay.
						/* 71 */
def {1} shared var v-F71 as char.
def {1} shared var v-bi like rem.bi.
						/* 72 */
def {1} shared var v-rcvinfo like rem.rcvinfo.
