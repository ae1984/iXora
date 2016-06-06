/* get100f.p
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


{mt100.i}
def var v-buf as char.
def shared var m-fnfull as char.

input through value("cat " + m-fnfull).




import v-sender.
import v-snddate.
import v-buf.
						/* 20 */

import v-ref.
						/* 32A */
/*
import v-F32.
*/
v-F32 = "A".

import v-buf .

if trim(v-buf) eq "" then v-valdt = ? .
else v-valdt = date(
integer(substring(v-buf,3,2)),
integer(substring(v-buf,5,2)),
integer(substring(v-buf,1,2)) + 1900).

import v-crccode.
import v-payment.
						/* 50 */

import v-ordcst[1].
import v-ordcst[2].
import v-ordcst[3].
import v-ordcst[4].
						/* 52 */
import v-F52 .
/*
import v-DC52.
*/
import v-ordinsact .
import v-ordins[1].
import v-ordins[2].
import v-ordins[3].
import v-ordins[4].
						/* 53 */
import v-F53 .
/*
import v-DC53.
*/
import v-sndcoract .
import v-sndcor[1].
import v-sndcor[2].
import v-sndcor[3].
import v-sndcor[4].
						/* 54 */
import v-F54 .
/*
import v-DC54.
*/
import v-rcvcoract .
import v-rcvcor[1].
import v-rcvcor[2].
import v-rcvcor[3].
import v-rcvcor[4].

						/* 56 */
import v-F56 .
/*
import v-DC56.
*/
import v-intmedact.
import v-intmed.
/*
v-intmed = trim(v-intmed) + fill(" ",35 - length(trim(v-intmed))).
import v-buf.
v-intmed = v-intmed + trim(v-buf) + fill(" ",35 - length(trim(v-buf))).
import v-buf.
v-intmed = v-intmed + trim(v-buf) + fill(" ",35 - length(trim(v-buf))).
import v-buf.
v-intmed = v-intmed + trim(v-buf) + fill(" ",35 - length(trim(v-buf))).
*/
						/* 57 */
import v-F57 .
/*
import v-DC57.
*/
import v-actinsact .
import v-actins[1].
import v-actins[2].
import v-actins[3].
import v-actins[4].

						/* 59 */
/*
import v-DC59.
*/
import v-ba .
import v-ben[1].
import v-ben[2].
import v-ben[3].
import v-ben[4].

						/* 70 */
import v-detpay[1].
import v-detpay[2].
import v-detpay[3].
import v-detpay[4].
						/* 71 */
import v-F71.
import v-bi.
						/* 72 */

import v-rcvinfo[1].
import v-rcvinfo[2].
import v-rcvinfo[3].
import v-rcvinfo[4].
import v-rcvinfo[5].
import v-rcvinfo[6].

input close.
pause 0.
