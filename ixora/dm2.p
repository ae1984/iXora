/* dm0.p
 * MODULE
        Реестр счетов-фактур
 * DESCRIPTION
        Ежеквартальная форма отчета в НК 
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
        09/03/04 suchkov
 * CHANGES

*/

define new shared variable i as integer initial 1.
define new shared variable d-s  as date initial 01/01/04 label "Начало периода".
define new shared variable d-po as date initial today label "Конец  периода".

define new shared temp-table t-reestr
    field nom   as   integer 
    field rnn   like debls.rnn
    field ser   like debls.ser
    field num   like debls.num
    field dop   as character 
    field nf    like debmon.nf
    field df    as character 
    field stoim like debmon.totsum
    field sum   like debmon.oblsum
    field nds   as decimal .

update d-s skip d-po with side-labels centered.

{r-branch.i &proc = "dm2_txb"} 

/* for each t-deb where t-deb.name = "" . delete t-deb. end. */

for each t-reestr no-lock .
    accumulate t-reestr.sum   (total).
    accumulate t-reestr.stoim (total).
    accumulate t-reestr.nds   (total).
end.

create t-reestr.
assign
t-reestr.nom   = 1
t-reestr.rnn   = "ИТОГО:"
t-reestr.ser   = " "
t-reestr.num   = " "
t-reestr.dop   = " "
t-reestr.nf    = " "
t-reestr.df    = " "
t-reestr.stoim = (accum TOTAL t-reestr.sum  )   
t-reestr.sum   = (accum TOTAL t-reestr.stoim) 
t-reestr.nds   = (accum TOTAL t-reestr.nds  ) .

output to oper.html.
    {html-title.i}
    put unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
                    "<TR style=""font:bold;font-size:18px"" align=""center"">"
                    "<TD colspan=9>" "РЕЕСТР СЧЕТОВ-ФАКТУР С " d-s " ПО " d-po 
                    "</TD></TR>" skip

                    "<TR style=""font:bold;font-size:12px"" align=""center"">"
                    "<TD>" "Номер"                              "</TD>"
                    "<TD>" "РНН"                                "</TD>"                                        
                    "<TD>" "Серия и номер свидетельства"        "</TD>"
                    "<TD>" "Дополнительный счет-фактура"        "</TD>"
                    "<TD>" "Номер счета-фактуры"                "</TD>"
                    "<TD>" "Дата счета-фактуры"                 "</TD>"
                    "<TD>" "Всего стоимость без НДС"            "</TD>"
                    "<TD>" "В том числе облагаемый оборот"      "</TD>"
                    "<TD>" "НДС, тенге"                         "</TD>"                                                            

                    "</TR>" skip.

for each t-reestr by nom.

    put unformatted "<TR style=""font-size:10px"">" .
    if t-reestr.nom > 1 then put unformatted "<TD>" t-reestr.nom - 1     "</TD>".
                        else put unformatted "<TD>"                      "</TD>".

    put unformatted "<TD>&nbsp;" t-reestr.rnn                      "</TD>"
                    "<TD>" t-reestr.ser " " t-reestr.num           "</TD>"
                    "<TD>" t-reestr.dop                            "</TD>"
                    "<TD>" t-reestr.nf                             "</TD>"
                    "<TD>" t-reestr.df                             "</TD>"
                    "<TD>" t-reestr.stoim format ">>>>>>>>>>>>>>>" "</TD>"
                    "<TD>" t-reestr.sum   format ">>>>>>>>>>>>>>>" "</TD>"
                    "<TD>" t-reestr.nds   format ">>>>>>>>>>>>>>>" "</TD>"
                    "</TR>" skip.
   
end.

output close.

unix silent cptwin oper.html excel.

