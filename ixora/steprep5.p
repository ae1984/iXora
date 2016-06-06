
{comm-txb.i}

def var ourbank as char.
def var ourcode as integer.
ourbank = comm-txb().
ourcode = comm-cod().

def var dt1 as date.
def var dt2 as date.
def var out as char. 
def shared var g-today as date.
dt1 = g-today.
dt2 = g-today.

define temp-table ttax like tax
    field id_nk as char format "x(4)".

define buffer btns for tns.                

update dt1 label "Дата"  
with centered frame df.

for each tax where date = dt1 and duid = ? and tns <> 0 and tns <> ? and comm.tax.txb = ourcode no-lock:
    create ttax.
    buffer-copy tax to ttax.
    ttax.id_nk = substr(tax.rnn_nk,1,4).
end.

output to rpt.img.
put unformatted  "Отчет о выданных справках об оплате налога на транспортное средство "
                 "за " dt1 format "99.99.9999" " г."
skip(1).

FOR EACH ttax NO-LOCK BREAK BY ttax.id_nk BY ttax.kb :

accumulate ttax.sum
    (sub-count by ttax.kb).
    
accumulate ttax.sum
    (sub-total by ttax.kb).

accumulate ttax.sum
    (sub-count by ttax.id_nk).
        
accumulate ttax.sum
    (sub-total by ttax.id_nk).

accumulate ttax.sum
    (count).
        
accumulate ttax.sum
    (total).
            
    IF FIRST-OF(ttax.id_nk) THEN do:
        find first taxnk where substring(taxnk.rnn,1,4) = ttax.id_nk no-lock.
        put unformatted skip(1) taxnk.name format "x(50)" skip(1).
        put unformatted
        fill("-", 100) format "x(100)" skip
        "N справки   N квит.    РНН             ФИО                 Сумма    Гос.номер     Марка тр/средства   " skip
        fill("-", 100) format "x(100)" skip.
    end.

/*    IF FIRST-OF(ttax.kb) THEN do:
        put unformatted "Платежи по коду " ttax.kb format "999999" skip
        fill("- ", 50) format "x(100)" skip.
    end.*/

    find first btns where btns.tns = ttax.tns no-lock no-error.
    if not avail btns then next.

    put ttax.tns format ">>>>>>>9" space(2)
        ttax.dnum format ">>>>>>>9" space(1)
        ttax.rnn  format "x(12)" space (1)
        btns.fio  format "x(20)" space (1)
        ttax.sum    format ">>>>>>>>>9.99" space(2)
        btns.number format "x(9)" space (1)
        btns.model  format "x(20)" space (1)
        skip.
    
/*    if last-of(ttax.kb) then do:
        put 
            Fill("- ", 50) format "x(100)" skip 
            "Всего по коду " ttax.kb format "999999" skip
            "платежей :" (accum sub-count by ttax.kb ttax.sum) format ">>>>>>>>>9" skip
            "на сумму :" (accum sub-total by ttax.kb ttax.sum) format ">>>>>>>>>>>>9.99"
            " тенге"
            skip(1).
    end.*/

    if last-of(ttax.id_nk) then do:
        put 
            fill("-", 100) format "x(100)" skip
            "Итого по НК " ttax.id_nk skip 
            "платежей :" (accum sub-count by ttax.id_nk ttax.sum) format ">>>>>>>>>>>>>>9" skip
            "на сумму :" (accum sub-total by ttax.id_nk ttax.sum) format ">>>>>>>>>>>>9.99"
            " тенге"
            skip(3).
    end.
                            
END.

put
    fill("=", 100) format "x(100)" skip(1)
    "Всего:" skip
            "платежей :" (accum count ttax.sum) format ">>>>>>>>>>>>>>9" skip
            "на сумму :" (accum total ttax.sum) format ">>>>>>>>>>>>9.99" skip.

output close.

run menu-prt("rpt.img").

out = substring(string(dt1,'999999'),5,2) + 
string(month(dt1),'99') + 
string(day(dt1),'99').

MESSAGE "Отправить реестр справок в НК ? "
        " Файл: tn" + out 
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE " Транспортный налог " UPDATE choiceout as logical.
    case choiceout:
       when false then return.
    end.        

unix SILENT value('cat rpt.img | koi2iso > tn' + out).

output through value("ftp -nc  192.168.1.132") no-echo.
put unformatted
"user tbank Paskuda1975" skip
"put" skip
"tn" out skip
"out/tn" out skip.
output close.
