/* pmujps1.f
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

def var vsh as inte initial 5.
def var v-qqqq as char initial ',' format "x(1)".
put stream m-doc

/*fill("-",130) format "x(130)" skip(1) */
 chr(27) + "E" format "x(2)" "КРЕДИТОВЫЙ ДОКУМЕНТ" 
 chr(27) + "F" format "x(2)" skip
"ПЛАТЕЖНОЕ ПОРУЧЕНИЕ " at 10 v-numurs
skip
v-ref at  23
skip

"ДАТА   : " v-mudate

"СУММА : " at 30 v-sm v-crccode
skip

v-sumt[1]  at 10
skip
v-sumt[2]  at 10
skip
/* "-----------------------------------------------------------------"
skip */

"Плательщик:" v-m1
"Счет : " at 44 v-km
skip

v-m2   "       " at 44 v-km1
skip
v-m3
skip
"Банк :" v-kbm v-qqqq v-bm1
skip
v-bm2
skip
v-bm3
skip
"-----------------------------------------------------------------"
skip

"Получатель:" chr(27) + "E" format "x(2)" v-s1 chr(27) + "F" format "x(2)"
"Счет : " at 44 v-ks

skip
v-s2
v-ks1 at 51
skip
v-s3 v-ks3 at 51
skip

"Банк :" v-kbs v-qqqq v-bs1
skip
v-bs2
skip
v-bs3
skip
"-----------------------------------------------------------------"
skip


v-detpay[1] "Є”””””””””””””””””””Џ" at 43
 skip

v-detpay[2] "ѓ     TexaKaBank    ѓ" at 43
 skip

v-detpay[3] "ѓ  Є”””””””””””””Џ  ѓ" at 43
 skip

v-detpay[4] "ѓ  ѓ" at 43 vdatu at 47 "ѓK1ѓ" at 60
skip

            "ѓ  ђ”””””””””””””©  ѓ" at 43
            skip

            "“”””””””””””””””””””„" at 43
            skip

            "ѓ  КОД   190501914  ѓ" at 43
            skip

            "ђ”””””””””””””””””””©" at 43
            skip


"Зачислено  " at 47
skip(1)

"М.П.          Подпись клиента      Подпись банка  " at 12
skip(1)

fill("=",80) format "x(80)" skip.
pause 0.
