/* dm1.p
 * MODULE
        Монитор дебиторов для Департамента Налогового Планирования и Департамента Внутрибанковских Операций
 * DESCRIPTION
        Предварительный отчет по дибеторам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        dm
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6.10
 * AUTHOR
        20/01/04 suchkov
 * CHANGES
        21/04/04 sasco Добавил колонку "Сумма НДС в зачет" (поле snds0)
*/

define variable i as integer initial 0.
define new shared variable d-s  as date initial 01/01/04 label "Начало периода".
define new shared variable d-po as date initial today label "Конец  периода".

define new shared temp-table t-deb
    field jdt   as   character 
    field prod  like debls.name
    field rnn   like debmon.rnn
    field ser   like debmon.ser
    field num   like debmon.num
    field nf    like debmon.nf
    field df    like debmon.df
    field nk    like debmon.nk
    field dk    as   character initial ""
    field name  like debmon.name
    field descr like debmon.descr
    field edizm like debmon.edizm
    field qty   like debmon.qty
    field sum   like debmon.totsum
    field obls  like debmon.oblsum
    field nds   like debmon.nds
    field snds  like debmon.sumnds

    FIELD snds0 like debmon.sumnds

    field prasp as   character 
    field pklas as   character 
    field aksum like debmon.aksum .

update d-s skip d-po with side-labels centered.

{r-branch.i &proc = "dm1_txb"}

output to oper.html.
    {html-title.i}
    put unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
                    "<TR style=""font:bold;font-size:18px"" align=""center"">"
                    "<TD>" "Сводные данные по списанию сумм с дебиторов c " d-s " по " d-po 
                    "</TD></TR>" skip

                    "<TR style=""font:bold;font-size:12px"" align=""center"">"
                    "<TD>" "Дата проводки"                      "</TD>"
                    "<TD>" "Дебитор"                            "</TD>"
                    "<TD>" "РНН"                                "</TD>"
                    "<TD>" "Серия"                              "</TD>"
                    "<TD>" "N свид."                            "</TD>"
                    "<TD>" "N Контракта"                        "</TD>"
                    "<TD>" "Дата конт."                         "</TD>"
                    "<TD>" "Ном. сч.факт."                      "</TD>"
                    "<TD>" "Дата сч.факт."                      "</TD>"
                    "<TD>" "Наименование товара"                "</TD>"
                    "<TD>" "Характеристика"                     "</TD>"
                    "<TD>" "Еди. изм."                          "</TD>"
                    "<TD>" "Кол-во"                             "</TD>"
                    "<TD>" "Сумма без НДС"                      "</TD>"
                    "<TD>" "Сумма облаг. об"                    "</TD>"
                    "<TD>" "Ставка НДС"                         "</TD>"
                    "<TD>" "Сумма НДС"                          "</TD>"
                    "<TD>" "Сумма НДС в зачет"                  "</TD>"
                    "<TD>" "Признак распределения"              "</TD>"
                    "<TD>" "Классиф. в реестре"                 "</TD>"
                    "<TD>" "Акцизы"                             "</TD>"
                    "</TR>" skip.

for each t-deb.

    put unformatted "<TR style=""font-size:10px"">"
                    "<TD>" t-deb.jdt        "</TD>"
                    "<TD>" t-deb.prod       "</TD>"
                    "<TD>&nbsp;" t-deb.rnn  "</TD>"
                    "<TD>&nbsp;" t-deb.ser  "</TD>"
                    "<TD>&nbsp;" t-deb.num  "</TD>"
                    "<TD>&nbsp;" t-deb.nk   "</TD>"
                    "<TD>" t-deb.dk         "</TD>"
                    "<TD>&nbsp;" t-deb.nf   "</TD>"
                    "<TD>" t-deb.df         "</TD>"
                    "<TD>" t-deb.name       "</TD>"
                    "<TD>" t-deb.descr      "</TD>"
                    "<TD>" t-deb.edizm      "</TD>"
                    "<TD>" replace(string(t-deb.qty, 'zzzzz9.9999'),'.',',') "</TD>"
                    "<TD>" t-deb.sum  format ">>>>>>>>>>>>>>>" "</TD>"
                    "<TD>" t-deb.obls format ">>>>>>>>>>>>>>>" "</TD>"
                    "<TD>" t-deb.nds        "</TD>"
                    "<TD>" t-deb.snds format ">>>>>>>>>>>>>>>" "</TD>"
                    "<TD>" t-deb.snds0 format ">>>>>>>>>>>>>>>" "</TD>"
                    "<TD>" t-deb.prasp      "</TD>"
                    "<TD>" t-deb.pklas      "</TD>"
                    "<TD>" t-deb.aksum      "</TD>"
                    "</TR>" skip.
   
end.

output close.

unix silent cptwin oper.html excel.
