/* h-docs.p
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
        22.01.2009 galina - показывать возврат или нет для актов.
        29.06.2012 damir  - добавил vcdocs.kod14,vcpartners.name,vcdocs.knp в form, индекс dndate.
        02.06.2012 damir  - добавил v-partner.
*/

        /* h-docs.p Валютный контроль
        Поиск документов

        18.10.2002 nadejda создан
*/

{vc.i}

def shared var s-contract like vccontrs.contract.
def shared var s-vcdoctypes as char.
def shared var s-dnvid as char.
def shared var s-docs like vcdocs.docs.

def var v-partner as char.

{global.i}

find first vcdocs where vcdocs.contract = s-contract and index(s-vcdoctypes, vcdocs.dntype) > 0 no-lock no-error.

if avail vcdocs then do:
    {jabro.i
    &head       =   "vcdocs"
    &headkey    =   "docs"
    &formname   =   "h-docs"
    &framename  =   "h-docs"
    &where      =   " (vcdocs.contract = s-contract) and (lookup(vcdocs.dntype, s-vcdoctypes) > 0)  "
    &index      =   "dndate"
    &addcon     =   "false"
    &deletecon  =   "false"
    &predisplay =   " find codfr where codfr.codfr = 'vcdoc' and codfr.code = vcdocs.dntype no-lock no-error.
                    find ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.
                    find comm.vcpartners where comm.vcpartners.partner = vcdocs.info[4] no-lock no-error.
                    if avail comm.vcpartners then v-partner = vcpartners.name. else v-partner = ''. "
    &display    =   " vcdocs.dnnum codfr.name[2] vcdocs.origin vcdocs.dndate vcdocs.sum ncrc.code vcdocs.payret when (index(s-dnvid, 'p') > 0) or
                    (index(s-dnvid, 'g') > 0)  or (index(s-dnvid, 'o') > 0) vcdocs.kod14 v-partner vcdocs.knp "
    &highlight  =   " vcdocs.dndate vcdocs.dnnum codfr.name[2] vcdocs.origin vcdocs.sum ncrc.code vcdocs.payret vcdocs.kod14 v-partner vcdocs.knp "
    &postkey    =   " else if keyfunction(lastkey) = 'return' then do:
                        s-docs = vcdocs.docs.
                        leave upper.
                    end. "
    &end        =   " hide frame h-docs. "
    }
end.
else do: message " Документы данного типа не найдены.". pause. end.




