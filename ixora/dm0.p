/* dm0.p
 * MODULE
        Монитор дебиторов для Департамента Налогового Планирования и Департамента Внутрибанковских Операций
 * DESCRIPTION
        Ежемесячная форма отчета в НК (КНИГА ПОКУПОК)
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
        25/02/04 suchkov
 * CHANGES

*/

define new shared variable i as integer initial 0.
define new shared variable j as integer initial 6.
define new shared variable d-s  as date initial 01/01/04 label "Начало периода".
define new shared variable d-po as date initial today label "Конец  периода".
define new shared variable v-spisok as character initial "ТМЗ,Коммунальные услуги,Услуги связи,Командировочные расходы,Банковские операции".

define new shared temp-table t-deb
    field nom   as   integer 
    field jdt   as   character 
    field prod  like debls.name
    field rnn   like debmon.rnn
    field res   like debls.res
    field nf    like debmon.nf
    field df    as   character initial ""
    field nk    like debmon.nk
    field dk    as   character initial ""
    field name1 like debmon.name
    field name2 like debmon.name
    field edizm like debmon.edizm
    field qty   like debmon.qty
    field sum   like debmon.totsum initial 0
    field stoim like debmon.totsum 
    field nds   like debmon.nds
    field snds  like debmon.sumnds initial 0
    field prasp as   character 
    field pklas as   character 
    field taxsum like debmon.taxsum initial 0
    field ptsum like debmon.ptsum initial 0
    field aksum like debmon.aksum initial 0.

define buffer bt-deb for t-deb .

update d-s skip d-po with side-labels centered.

{r-branch.i &proc = "dm0_txb"}

for each t-deb where t-deb.name1 = "" . delete t-deb. end.

for each t-deb break by t-deb.name1.
    accumulate t-deb.sum     (total).
    accumulate t-deb.snds    (total).
    accumulate t-deb.taxsum  (total).
    accumulate t-deb.ptsum   (total).
    accumulate t-deb.aksum   (total).
    i = lookup(t-deb.name1, v-spisok) + 1.
    if i > 1 then do:
        find bt-deb where bt-deb.nom = i no-error .
        if not available bt-deb then create bt-deb.
        assign
        bt-deb.nom   = i
        bt-deb.prod  = " "                        
        bt-deb.rnn   = " "                        
        bt-deb.res   = " " 
        bt-deb.nf    = " "                        
        bt-deb.df    = " "                        
        bt-deb.nk    = " "                        
        bt-deb.name1 = t-deb.name1
        bt-deb.edizm = " "
        bt-deb.stoim = 0
        bt-deb.qty   = 1                          
        bt-deb.sum   = bt-deb.sum + t-deb.sum  
        bt-deb.nds   = t-deb.nds
        bt-deb.snds  = bt-deb.snds + t-deb.snds
        bt-deb.aksum = bt-deb.aksum + t-deb.aksum 
        bt-deb.taxsum = bt-deb.taxsum + t-deb.taxsum
        bt-deb.ptsum = bt-deb.ptsum + t-deb.ptsum .
        delete t-deb.
    end.
end.

create t-deb.
assign
t-deb.nom   = 1
t-deb.prod  = " "                        
t-deb.rnn   = " "                        
t-deb.res   = " " 
t-deb.nf    = " "                        
t-deb.df    = " "                        
t-deb.nk    = " "                        
t-deb.name1 = "Всего:"
t-deb.edizm = " "
t-deb.stoim = 0
t-deb.qty   = 1                          
t-deb.sum   = (accum TOTAL t-deb.sum)
t-deb.nds   = 0
t-deb.snds  =  (accum TOTAL t-deb.snds  )
t-deb.aksum =  (accum TOTAL t-deb.aksum)
t-deb.taxsum = (accum TOTAL t-deb.taxsum )
t-deb.ptsum =  (accum TOTAL t-deb.ptsum ) .

output to oper.html.
    {html-title.i}
    put unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
                    "<TR style=""font:bold;font-size:18px"" align=""center"">"
                    "<TD colspan=19>" "КНИГА ПОКУПОК С" d-s " ПО " d-po 
                    "</TD></TR>" skip

                    "<TR style=""font:bold;font-size:12px"" align=""center"">"
                    "<TD>" "Номер"                              "</TD>"
                    "<TD>" "Наименование товара (работ, услуг)" "</TD>"
                    "<TD>" "Залог"                              "</TD>"
                    "<TD>" "Наименование продавца"              "</TD>"
                    "<TD>" "РНН"                                "</TD>"                                        
                    "<TD>" "Код страны резид-ва"                "</TD>"
                    "<TD>" "N контракта (договора)"             "</TD>"
                    "<TD>" "Дата контракта (договора)"          "</TD>"
                    "<TD>" "Дата счета-фактуры"                 "</TD>"
                    "<TD>" "Номер счета-фактуры"                "</TD>"                    
                    "<TD>" "Единицы измерения"                  "</TD>"
                    "<TD>" "Стоимость единицы товара, тг."      "</TD>"
                    "<TD>" "Количество"                         "</TD>"
                    "<TD>" "Сумма, тенге"                       "</TD>"
                    "<TD>" "Ставка НДС, %"                      "</TD>"
                    "<TD>" "НДС, тенге"                         "</TD>"                                                            
                    "<TD>" "Акцизы, тенге"                      "</TD>"
                    "<TD>" "Таможенные пошлины и сборы, тенге"  "</TD>"
               "<TD>Сумма подоходного налога у источника выплаты, тенге</TD>"
                    "</TR>" skip.

i = 0.
for each t-deb by nom.
    i = i + 1.
    put unformatted "<TR style=""font-size:10px"">" .
    if t-deb.nom > 6 then put unformatted "<TD>" i - 6                 "</TD>".
                     else put unformatted "<TD>"                       "</TD>".

    put unformatted "<TD>"       t-deb.name1 " " t-deb.name2           "</TD>"
                    "<TD>"                                             "</TD>"
                    "<TD>"       t-deb.prod                            "</TD>"
                    "<TD>&nbsp;" t-deb.rnn                             "</TD>"
                    "<TD>"       t-deb.res                             "</TD>"
                    "<TD>"       t-deb.nk                              "</TD>"
                    "<TD>"       t-deb.dk                              "</TD>"
                    "<TD>"       t-deb.df                              "</TD>"
                    "<TD>"       t-deb.nf                              "</TD>"
                    "<TD>"       t-deb.edizm                           "</TD>"
                    "<TD>"       t-deb.stoim  format ">>>>>>>>>>>>>>>" "</TD>"
                    "<TD>&nbsp;" t-deb.qty                             "</TD>"
                    "<TD>"       t-deb.sum    format ">>>>>>>>>>>>>>>" "</TD>"
                    "<TD>"       t-deb.nds                             "</TD>"
                    "<TD>"       t-deb.snds   format ">>>>>>>>>>>>>>>" "</TD>"
                    "<TD>"       t-deb.aksum  format ">>>>>>>>>>>>>>>" "</TD>"
                    "<TD>"       t-deb.taxsum format ">>>>>>>>>>>>>>>" "</TD>"
                    "<TD>"       t-deb.ptsum  format ">>>>>>>>>>>>>>>" "</TD>"
                    "</TR>" skip.
    
end.

output close.

unix silent cptwin oper.html excel.

