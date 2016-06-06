﻿/* jdd_tmpl.p
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
        21.04.10 marinav - добавилось третье поле примечания
        10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
*/

/** jdd_tmpl.p
    (D) KONTS -- (K) KONTS **/


define input  parameter j_basic as character.
define output parameter j_param as character.
define output parameter j_templ as character.

define buffer bcrc for crc.

define shared variable v_doc like joudoc.docnum.

define variable vdel as character initial "^".
define variable rcode   as integer.
define variable rdes    as character.
define variable jparr   as character format "x(20)".

define variable change as logical.

define variable d_amt      like joudoc.dramt.
define variable c_amt      like joudoc.cramt.
define variable com_amt    like joudoc.comamt.
define variable m_buy      as decimal.
define variable m_sell     as decimal.
define variable buy_rate   like joudoc.brate.
define variable sell_rate  like joudoc.srate.
define variable buy_n      like joudoc.bn.
define variable sell_n     like joudoc.sn.


find joudoc where joudoc.docnum eq v_doc no-lock no-error.
    if joudoc.drcur eq joudoc.crcur then do:
        j_param = joudoc.docnum + vdel + string (joudoc.dramt) + vdel +
            string (joudoc.drcur) + vdel + joudoc.dracc + vdel +
            joudoc.cracc + vdel + (joudoc.remark[1] + joudoc.remark[2] + joudoc.rescha[3]).
        j_templ = "JOU0022".
    end.
    else do:
        find crc where crc.crc eq joudoc.drcur no-lock no-error.

        if j_basic eq "D" then d_amt = joudoc.dramt.
        else if j_basic eq "C" then c_amt = joudoc.cramt.

        run conv (input joudoc.drcur, input joudoc.crcur, input false,
            input false, input-output d_amt, input-output c_amt,
            output buy_rate, output sell_rate, output buy_n, output sell_n,
            output m_buy, output m_sell).

            if buy_rate ne joudoc.brate then do:
                message substitute
                    ("ИЗМЕНИЛСЯ  &1  КУРС ПОКУПКИ. СУММА БУДЕТ ПЕРЕСЧИТАНА.",
                    crc.code).
                change = true.
            end.
        find bcrc where bcrc.crc eq joudoc.crcur no-lock no-error.
            if sell_rate  ne joudoc.srate then do:
                message substitute
                    ("ИЗМЕНИЛСЯ  &1  КУРС ПРОДАЖИ. СУММА БУДЕТ ПЕРЕСЧИТАНА.",
                    bcrc.code).
                change = true.
            end.

        if j_basic eq "D" then do:
            j_param = joudoc.docnum + vdel + string (joudoc.dramt) +
                vdel + string (joudoc.drcur) + vdel + joudoc.dracc + vdel +
                (joudoc.remark[1] + joudoc.remark[2] + joudoc.rescha[3]) + vdel +
                string (joudoc.crcur) + vdel +
                joudoc.cracc.

            j_templ = "JOU0023".

            if change then do:
                run trxsim("", j_templ, vdel, j_param, 5, output rcode,
                    output rdes, output jparr).
                    if rcode ne 0 then do:
                        message rdes.
                        pause 3.
                        undo, return.
                    end.

                find joudoc where joudoc.docnum eq v_doc exclusive-lock
                    no-error.
                joudoc.cramt = decimal (jparr).
                joudoc.brate = buy_rate.
                joudoc.srate = sell_rate.
                joudoc.bn    = buy_n.
                joudoc.sn    = sell_n.
            end.
        end.
        else if j_basic eq "C" then do:
            j_param = joudoc.docnum + vdel + string (joudoc.drcur) +
                vdel + joudoc.dracc + vdel +
                (joudoc.remark[1] + joudoc.remark[2] + joudoc.rescha[3]) + vdel +
                string (joudoc.cramt) + vdel + string (joudoc.crcur) + vdel +
                joudoc.cracc.

            j_templ = "JOU0024".

            if change then do:
                run trxsim("", j_templ, vdel, j_param, 3, output rcode,
                    output rdes, output jparr).
                    if rcode ne 0 then do:
                        message rdes.
                        pause 3.
                        undo, return.
                    end.
                find joudoc where joudoc.docnum eq v_doc exclusive-lock                              no-error.
                joudoc.dramt = decimal (jparr).
                joudoc.brate = buy_rate.
                joudoc.srate = sell_rate.
                joudoc.bn    = buy_n.
                joudoc.sn    = sell_n.
            end.
        end.
    end.