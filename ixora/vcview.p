/* vcview.p
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

        21.07.04 saltanat - Добавлен вывод данных в Excel, Word.
        13.11.09 marinav  можно редактировать
        26/05/2011 dmitriy - запрещено редактирование из филиалов, кроме ЦО
                           - синхронизация по всем филиалам
*/

/* vcview.p Валютный контроль
   Просмотр справочников

   18.10.2002 nadejda создан

*/

{yes-no.i}

def new shared temp-table wrk
   field codfr as char
   field code as char
   field intcode as integer
   field name as char
   field papa as char
   field child as logical
   field tree-node as char.

define variable s_rowid as rowid.
def  shared var g-lang as char.
def buffer b_codfr for codfr.
def input parameter s-codfr as char.
def input parameter codemask as char.
def var codific-name as char.
def new shared var v-name as char.
def var codname as char.
def new shared var v-code as char.
def new shared var v-codfr as char.
v-codfr = s-codfr.

def var s-ourbank as char no-undo.
find bank.sysc where bank.sysc.sysc = "ourbnk" no-lock no-error.

s-ourbank = trim(bank.sysc.chval).

find first codific where codific.codfr = s-codfr no-lock no-error.
if available codific then codific-name = codific.name.

{jabro.i

&start     =  " "
&head      =  "codfr"
&headkey   =  "codfr"
&index     =  "codfr_idx"
&formname  =  "uni_help1"
&framename =  "uni_help1"
&where     =  " codfr.codfr = s-codfr and codfr.child = false
            and codfr.code <> 'msc' and codfr.code matches codemask "
&addcon    =  "true"
&deletecon =  "true"
&predelete =  "if s-ourbank <> 'txb00' then do:
                 message 'Удаление только в базе ЦО!'.
                 next upper.
               end."
&precreate =  " "
&postadd   =  "if s-ourbank <> 'txb00' then do:
                  message 'Редактирование только в базе ЦО!'.
               end.
               else do:
                  codfr.codfr = s-codfr. codfr.level = 1.
                  update codfr.code v-name with frame uni_help1.  codfr.name[1] = v-name.
               end.
              "
&prechoose =  "displ '< F4 > - выход,  < W > - Word, < E > - Excel'
               with centered row 22 no-box frame vcfooter. "
&postkey   = " if keyfunction(lastkey) = 'return' and s-ourbank = 'txb00' then do transaction:
                    find codfr where recid(codfr) = crec exclusive-lock.
                    v-name =   codfr.name[1] + codfr.name[2] + codfr.name[3] + codfr.name[4] + codfr.name[5].
                    v-code = codfr.code.
                    update v-name with frame uni_help1 .
                    codfr.name[1] = v-name. codfr.name[2] = ''. codfr.name[3] = ''. codfr.name[4] = ''. codfr.name[5] = ''.
                    find codfr where recid(codfr) = crec no-lock no-error.
               end.
                else if keyfunction(lastkey) = 'W' then do:
                    if yes-no ('', 'Вы действительно хотите вывести данные в Word ?') then do:
                        s_rowid = rowid(codfr).
                        output to vcdata.img .
                        displ 'КОДЫ НАЗНАЧЕНИЯ ПЛАТЕЖА' skip(1).
                        displ 'КОД' '    '
                        'НАИМЕНОВАНИЕ'.
                        put fill('=',75) format 'x(75)' skip.
                        for each codfr where codfr.codfr = s-codfr and codfr.child = false
                        and codfr.code <> 'msc' and codfr.code matches codemask no-lock:
                            put unformatted codfr.code '   '
                            codfr.name[1] + codfr.name[2] + codfr.name[3] + codfr.name[4] + codfr.name[5] skip.
                        end.
                        output close.
                        unix silent cptwin vcdata.img winword.
                    end.
                end.
                else if keyfunction(lastkey) = 'E' then  do:
                    if yes-no ('', 'Вы действительно хотите вывести данные в Excel ?') then do:
                        s_rowid = rowid(codfr).
                        output to vcdata.csv .
                        displ 'КОДЫ НАЗНАЧЕНИЯ ПЛАТЕЖА' skip(1).
                        displ 'КОД' ' ; '
                        'НАИМЕНОВАНИЕ'.
                        put fill('=',75) format 'x(75)' skip.
                        for each codfr where codfr.codfr = s-codfr and codfr.child = false
                        and codfr.code <> 'msc' and codfr.code matches codemask no-lock:
                            put unformatted '''' + codfr.code ' ; '
                            codfr.name[1] + codfr.name[2] + codfr.name[3] + codfr.name[4] + codfr.name[5] skip.
                        end.
                        output close.
                        unix silent cptwin vcdata.csv excel.
                    end.
                end."
&predisplay = " v-name = codfr.name[1] + codfr.name[2] + codfr.name[3]. "
&display   =  " codfr.code v-name "
&highlight =  "codfr.code"
&end =        " hide frame uni_help1."

}

if s-ourbank = 'txb00' then do:
    if yes-no ('', 'Синхронизировать изменения в Справочнике кодов бюджета с филиалами?') then do:
        displ ' Синхронизация Справочника кодов бюджета с филиалами... ' with no-label row 7 centered frame vmess.
        run branch.
        hide frame vmess.
    end.
end.


procedure branch:
{r-branch.i &proc = 'vcvknp-txb'}
end procedure.

