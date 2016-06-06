/* h-ps.p
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
 * BASES
        BANK COMM
 * CHANGES
*/      /* h-ps.p Валютный контроль
        Поиск-список паспортов сделок/доплистов

        18.10.2002 nadejda создан
        25.03.2008 galina - изменен формат вывода номера документа
        11.03.2011 damir  - перекомпиляция в связи с добавлением нового поля opertyp
        29.06.2012 damir  - сортирование по индексу dndate.

*/

{vc.i}

def shared var s-contract like vccontrs.contract.
def shared var s-ps like vcps.ps.
def var v-dnnum as char.

{global.i}

find first vcps where vcps.contract = s-contract no-lock no-error.
if avail vcps then do:
    {
    jabro.i
    &head         = "vcps"
    &headkey      = "ps"
    &formname     = "h-ps"
    &framename    = "h-ps"
    &where        = " (vcps.contract = s-contract) "
    &index        = "dndate"
    &addcon       = "false"
    &deletecon    = "false"
    &predisplay   = " find codfr where codfr.codfr = 'vcdoc' and codfr.code = vcps.dntype no-lock no-error.
                    if avail codfr then do:
                        if vcps.dntype = '01' then v-dnnum = vcps.dnnum + string(vcps.num).
                        else v-dnnum = vcps.dnnum.
                    end.
                    find ncrc where ncrc.crc = vcps.ncrc no-lock no-error.  "
    &display      = " v-dnnum codfr.name[2] vcps.dndate vcps.sum ncrc.code vcps.lastdate "
    &highlight    = " vcps.dndate v-dnnum codfr.name[2] vcps.sum ncrc.code vcps.lastdate "
    &postkey      = " else if keyfunction(lastkey) = 'return' then do:
                        s-ps = vcps.ps.
                        leave upper.
                    end. "
    &end          = " hide frame h-ps."
    }
end.
else do: message " Документы не найдены.". pause. end.

