/* vcctsts.p
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
*/      /* vcctsts.p - изменение статуса контракта
        Сделано отдельно, чтобы можно было менять статус после акцепта

        30.10.2002 nadejda создан
        07.04.2008 galina - добавлен выбор основания закрытия контракта из справочника
        02.07.2008 galina - присваиваем полю Основание закрытия контракта значение из спарвочника, а не номер по порядку
        09.01.2009 galina - добавила редактирование поля Основание закрытия контракта
        14.08.2009 galina - перекомпиляция в связи с изменением vccontrs.f
        11.03.2011 damir  - перекомпиляция в связи с добавлением нового поля opertyp
        04.08.2011 damir  - объявил переменные v-valogov1,v-valogov2
        08.08.2011 aigul  - вывод инфы по ИНН, счета получателя, банк бенефициара, банк-корреспондент
        09.09.2011 damir  - объявил переменную v-check.
        29.06.2012 damir  - vccontrs.sts <> "C".
        12.07.2012 damir  - для типов контрактов кроме 1 возможно изменение статуса (если контракт уже закрыт).
        */

{vc.i}

{global.i}

def shared var s-contract like vccontrs.contract.
def shared var v-cifname as char.
def shared frame vccontrs.

def var v-valogov1 as char.
def var v-valogov2 as char.
def var v-bb as char.
def var v-bb1 as char.
def var v-bb2 as char.
def var v-bb3 as char.

def var v-bc as char.
def var v-bc1 as char.
def var v-bc2 as char.
def var v-bc3 as char .
def var v-check as logi init no.

{vccontrs.f}

do transaction on error undo, retry:
    find vccontrs where vccontrs.contract = s-contract exclusive-lock no-error.
    if avail vccontrs and ((vccontrs.sts <> "C" and vccontrs.cttype = "1") or (vccontrs.cttype <> "1")) then update vccontrs.sts with frame vccontrs.
    if vccontrs.sts begins 'C' then update vccontrs.info[8] with frame vccontrs.
    else do:
        vccontrs.info[8] = "".
        display vccontrs.info[8] with frame vccontrs.
    end.
end.
find current vccontrs no-lock.


