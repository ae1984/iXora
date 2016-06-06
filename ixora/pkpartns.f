/* pkpartns.f
 * MODULE
        ПОТРЕБКРЕДИТ
 * DESCRIPTION
        Форма редактирования справочника предприятий-партнеров
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
        11.03.2003 nadejda
 * BASES
        BANK COMM
 * CHANGES
        28.01.2004 sasco расширил поле видов кредита
        03.02.2004 sasco добавил ввод %% по вознаграждению
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

def var v-intext as logical.
/*
def var v-ctname as char.
*/
def var v-ctname as decimal format "z9.99".

form
     codfr.code format "x(10)" label "ТЕК.СЧЕТ" help " Т/счет предприятия-партнера"
     codfr.name[1] format "x(37)" label "ПОЛНОЕ НАИМЕНОВАНИЕ" help " Наименование предприятия-партнера для анкеты и заявления"
     v-intext format "да/нет" label "ВНУТР?" help " Внутренний перевод денег на счет преприятия-партнера?"
     codfr.name[5] format "x(8)" label "КОД" help " Вид кредита, по которому данное предприятие является партнером"
/*     v-ctname format "x(8)" label "Вознагр." */
     v-ctname label "Возн. %%"
     with row 5 centered width 80 scroll 1 12 down frame fed.
