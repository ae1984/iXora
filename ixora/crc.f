/* crc.f
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
        07.04.2011 aigul - сделала проверку для ПРОДАжА - ПОКУПКА НАЛИЧН
        08.04.2011 aigul - исправила проверку на курсы, кроме Фунтов
        24.03.2011 aigul - добавила проверку курсов с опрными курсами.
        25.04.2011 aigul - убрала проверку для админов
        22.07.2011 aigul - передала значание в v-rate1
        25.07.2011 aigul - v-rate1 = 0.
*/
def var msg-err as char.
def buffer b-scrc for scrc.
def var  v-buy  as decimal.
def var  v-sell  as decimal.
def var  v-spred  as decimal.
def var v-rate1 as decimal.
def var v-rate2 as decimal.
def var v-chk as logical initial no.
def var v-order as int.
v-rate1 = 0.
function chk-rate2 returns logical (p-value as decimal).
    v-rate1 = p-value.
    if (g-ofc = "bankadm" or g-ofc = "id00700" or g-ofc = "id00477") then return true.
    else do:
        v-chk = no.
        if crc.crc <> 6 and p-value <= 0 then do:
            msg-err = " Неверный курс!".
            return false.
        end.
        for each scrc where scrc.crc = crc.crc no-lock break by scrc.scrc:
            find last b-scrc where b-scrc.scrc = scrc.scrc no-lock no-error.
            if avail b-scrc then do:
                v-buy = b-scrc.buycrc.
                v-chk = yes.
            end.
        end.
        if v-chk then do:
            if p-value > v-buy then do:
                msg-err = " Неверный курс!".
                return false.
            end.
        end.
        return true.
        v-chk = no.
    end.
end.
function chk-rate3 returns logical (p-value1 as decimal).
    if (g-ofc = "bankadm" or g-ofc = "id00700" or g-ofc = "id00477") then return true.
    else do:
        v-chk = no.
        if crc.crc <> 6 and p-value1 <= 0 then do:
            msg-err = "1 Неверный курс!".
            return false.
        end.
        for each scrc where scrc.crc = crc.crc no-lock break by scrc.scrc:
            find last b-scrc where b-scrc.scrc = scrc.scrc no-lock no-error.
            if avail b-scrc then do:
                v-sell = b-scrc.sellcrc.
                v-spred = b-scrc.minspr.
                v-chk = yes.
                v-order = b-scrc.order.
            end.
        end.
        if v-chk then do:
            if p-value1 < v-sell then do:
                msg-err = "2 Неверный курс!".
                return false.
            end.
            if p-value1 - v-rate1 < v-spred  then do:
                msg-err = "3 Неверный курс!" +  string(p-value1) + " " + string(v-rate1) +  " " + string(v-spred) .
                return false.
            end.
        end.
        return true.
    end.
end.



form crc.crc LABEL "ВАЛ" FORMAT 'Z9'
     crc.des  LABEL "НАЗВАНИЕ ВАЛюТЫ" FORMAT "X(23)"
     crc.rate[1] LABEL "КУРС KZT "  format "zzzz.9999"
     crc.rate[9] label "РАЗМЕРНОСТЬ" format "z,zzz,zz9 "
     crc.decpnt  label "ДЕСЯТ."
     crc.code    LABEL "КОД "
     crchis.rdt label "РЕГ.ДАТА"
     t9 validate(t9 = 'H' or t9 = 'S' or t9 = 'L',"Некорректн.вид")
     label "H/S"  with  centered row  3 down frame crc.
form crc.rate[2] label "ПОКУПКА НАЛИЧН.  " validate(chk-rate2(crc.rate[2]), msg-err) skip
     crc.rate[3] label "ПРОДАжА НАЛИЧН.  " validate(chk-rate3(crc.rate[3]), msg-err) skip
     crc.rate[4] label "ПОКУПКА БЕЗНАЛИЧН"
     crc.rate[5] label "ПРОДАжА БЕЗНАЛИЧН"
     crc.rate[6] label "ПОКУПКА ДОР.ЧЕК. "
     crc.rate[7] label "ПРОДАжА ДОР.ЧЕК. "
     with row 5 centered 1 col 1 down overlay top-only frame rate.
