/* eknpjss.p
 * MODULE
        Название модуля - Внутрибанковские операции
 * DESCRIPTION
        Описание - Форма-3 (движение денег на банковских счетах)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - eknp_f3.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 8.8.6.5
 * BASES
        BANK COMM TXB
 * AUTHOR
        05/04/2006 dpuchkov
 * CHANGES
        11.04.2006 dpuchkov - добавил нумерацию
        20.04.2006 dpuchkov - Изменил формат вывода в тысячных
        30.03.2011 marinav - добавили КНП
        21.12.2012 damir - Отчет работал неправильно. Доработано с последними изменения НБРК. Внедрено Т.З. № 1620.
*/
{eknpjss_var.i}
{conv.i}
{nbankBik-txb.i}
{replacebnk.i}
{chbin_txb.i}

def temp-table tk-cif like txb.cif.
def temp-table tk-aaa like txb.aaa.

def temp-table tk-kod
    field kod as integer
    field knp as char
    field ps  as char
    field rez as char.

def var file as char init "eknpjss.htm".
def var KOd as char format "x(2)" no-undo.
def var KBe as char format "x(2)" no-undo.
def var KNP as char format "x(3)" no-undo.

def var v-storned as logi.
def var v-KOd as char.
def var v-KBe as char.
def var v-KNP as char.
def var v-ourbnk as char.
def var v-filnam as char.
def var v-inbal as deci.
def var v-outbal as deci.
def var s-jh as inte.

def var ix as integer init 0.
def var d-usd as decimal.
def var d-eur as decimal.
def var d-rur as decimal.

def var z_knp as char.
def var z_rez as char.

def var v-dam as deci.
def var v-cam as deci.
def var v-naznplat as char.
def var v-addanother as logi.

def var v-codd as char.
def var v-cod1 as char.
def var v-cod2 as char.
def var d-codd as inte.
def var i_tkod as inte.

def temp-table t-dtall
    field num as integer
    field name as char
    field kod as integer
    field allus as decimal decimals 2
    field alleu as decimal decimals 2
    field allru as decimal decimals 2.

def temp-table t-dtacc
    field num as integer
    field aaa like txb.aaa.aaa
    field crc like txb.crc.crc.

def temp-table t1
    field kod as integer
    field name as char.

def temp-table t2
    field kod as integer
    field aaa as char
    field usd as decimal
    field eur as decimal
    field rur as decimal .

def buffer bt-t1 for t1.
def buffer b1-t2 for t2.
def buffer b2-t2 for t2.
def buffer b3-t2 for t2.
def buffer b4-t2 for t2.
def buffer b5-t2 for t2.
def buffer b6-t2 for t2.
def buffer b1-crc for txb.crc.
def buffer b2-crc for txb.crc.

empty temp-table tk-aaa.
empty temp-table tk-kod.
empty temp-table t1.
empty temp-table t2.

if v-jss = "" then return.
find last txb.cif where txb.cif.bin = v-jss no-lock no-error.
if not avail txb.cif then return.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if avail txb.sysc then v-ourbnk = trim(txb.sysc.chval).

find txb.cmp no-lock no-error.
if avail txb.cmp then v-filnam = trim(txb.cmp.name).

for each txb.aaa where txb.aaa.cif = txb.cif.cif and txb.aaa.sta <> "C" and txb.aaa.crc <> 1 no-lock:
    find txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
    if txb.lgr.led = 'ODA' then next.

    create tk-aaa.
    tk-aaa.aaa = txb.aaa.aaa.
    tk-aaa.cif = txb.aaa.cif.
    tk-aaa.crc = txb.aaa.crc.
end.

find last tk-aaa where tk-aaa.cif = txb.cif.cif no-lock no-error.
if not avail tk-aaa then return.

function GetKNP returns char(input p-knp as char).
    def var v-res as char.
    def var i as inte.
    def var j as inte.
    def var v-aaa as char.
    def var v-bbb as char.

    v-res = "".
    do i = 1 to num-entries(p-knp):
        v-aaa = entry(i,p-knp).
        if substr(v-aaa,3,1) = "0" then do:
            do j = 0 to 9:
                v-bbb = substr(v-aaa,1,2) + string(j).
                if v-res <> ""  then v-res = v-res + "," + v-bbb.
                else v-res = v-bbb.
            end.
        end.
        else do:
            if v-res <> ""  then v-res = v-res + "," + v-aaa.
            else v-res = v-aaa.
        end.
    end.
    return v-res.
end function.

procedure addanother.
    def input parameter p-kod as inte.
    def input parameter p-sum as deci.

    def buffer buf-t2 for t2.

    if p-kod = 221160 then do:
        find last buf-t2 where buf-t2.kod = 220500 and buf-t2.aaa = tk-aaa.aaa no-error.
        if not avail buf-t2 then
        create buf-t2.
        buf-t2.kod = 220500.
        buf-t2.aaa = tk-aaa.aaa.

        if tk-aaa.crc = 2 then buf-t2.usd = buf-t2.usd + round(p-sum / 1000, 2).
        if tk-aaa.crc = 3 then buf-t2.eur = buf-t2.eur + round(p-sum / 1000, 2).
        if tk-aaa.crc = 4 then buf-t2.rur = buf-t2.rur + round(p-sum / 1000, 2).

        v-addanother = true.
    end.
    if p-kod = 221141 or p-kod = 221142 then do:
        if z_rez = "1" then do:
            find last buf-t2 where buf-t2.kod = 221140 and buf-t2.aaa = tk-aaa.aaa no-error.
            if not avail buf-t2 then
            create buf-t2.
            buf-t2.kod = 221140.
            buf-t2.aaa = tk-aaa.aaa.

            if tk-aaa.crc = 2 then buf-t2.usd = buf-t2.usd + round(p-sum / 1000, 2).
            if tk-aaa.crc = 3 then buf-t2.eur = buf-t2.eur + round(p-sum / 1000, 2).
            if tk-aaa.crc = 4 then buf-t2.rur = buf-t2.rur + round(p-sum / 1000, 2).
        end.
        v-addanother = true.
    end.
    if p-kod = 222141 or p-kod = 222142 then do:
        if z_rez = "2" then do:
            find last buf-t2 where buf-t2.kod = 222140 and buf-t2.aaa = tk-aaa.aaa no-error.
            if not avail buf-t2 then
            create buf-t2.
            buf-t2.kod = 222140.
            buf-t2.aaa = tk-aaa.aaa.

            if tk-aaa.crc = 2 then buf-t2.usd = buf-t2.usd + round(p-sum / 1000, 2).
            if tk-aaa.crc = 3 then buf-t2.eur = buf-t2.eur + round(p-sum / 1000, 2).
            if tk-aaa.crc = 4 then buf-t2.rur = buf-t2.rur + round(p-sum / 1000, 2).
        end.
        v-addanother = true.
    end.
end.

/*Поступление средств на счет клиента*/
create tk-kod. tk-kod.ps = "p". tk-kod.rez = "1". tk-kod.kod = 211110. tk-kod.knp = GetKNP("222,229,710,720,730,740"). /*"710,730,222,229,721,722,740".*/
create tk-kod. tk-kod.ps = "p". tk-kod.rez = "1". tk-kod.kod = 211120. tk-kod.knp = GetKNP("810,820,830,840,850,860,870"). /*"811,812,813,814,815,816,817,818,819,820,831,832,833,834,835,836,837,839,840,851,852,853,854,855,856,859,860,861,862,869,870".*/
create tk-kod. tk-kod.ps = "p". tk-kod.rez = "1". tk-kod.kod = 211130. tk-kod.knp = GetKNP("420,580,680"). /*"421,423,424,429,580,681,682".*/
create tk-kod. tk-kod.ps = "p". tk-kod.rez = "1". tk-kod.kod = 211141. tk-kod.knp = GetKNP("410,570,670"). /*"411,413,419,570,671,672".*/
create tk-kod. tk-kod.ps = "p". tk-kod.rez = "2". tk-kod.kod = 211142. tk-kod.knp = GetKNP("410,570,670"). /*"411,413,419,570,671,672".*/
create tk-kod. tk-kod.ps = "p". tk-kod.rez = "1". tk-kod.kod = 211151. tk-kod.knp = GetKNP("610,620,630,640,650,660"). /*"610,621,623,629,631,633,639,641,642,645,647,648,649,651,652,655,657,658,661,662,663".*/
create tk-kod. tk-kod.ps = "p". tk-kod.rez = "2". tk-kod.kod = 211152. tk-kod.knp = GetKNP("510,520,530,540,550,560"). /*"510,521,522,529,531,532,539,541,542,543,544,545,548,549,551,552,553,554,555,558,559,561,562,563".*/
create tk-kod. tk-kod.ps = "p". tk-kod.rez = "1". tk-kod.kod = 211160. tk-kod.knp = GetKNP("110,120,140,170,180,190,290,310,390,490,590,690,780,790,880,890"). /*"111,112,119,120,140,171,172,181,182,190,290,311,312,314,319,390,490,590,690,780,790,880,890".*/

create tk-kod. tk-kod.ps = "p". tk-kod.rez = "2". tk-kod.kod = 212110. tk-kod.knp = GetKNP("222,229,710,720,730,740"). /*"710,730,222,229,721,722,740".*/
create tk-kod. tk-kod.ps = "p". tk-kod.rez = "2". tk-kod.kod = 212120. tk-kod.knp = GetKNP("810,820,830,840,850,860,870"). /*"811,812,813,814,815,816,817,818,819,820,831,832,833,834,835,836,837,839,840,851,852,853,854,855,856,859,861,862,869,870".*/
create tk-kod. tk-kod.ps = "p". tk-kod.rez = "2". tk-kod.kod = 212130. tk-kod.knp = GetKNP("420,580,680"). /*"421,423,424,429,580,681,682".*/
create tk-kod. tk-kod.ps = "p". tk-kod.rez = "1". tk-kod.kod = 212141. tk-kod.knp = GetKNP("410,570,670"). /*"421,423,424,429,580,681,682".*/
create tk-kod. tk-kod.ps = "p". tk-kod.rez = "2". tk-kod.kod = 212142. tk-kod.knp = GetKNP("410,570,670"). /*"421,423,424,429,580,681,682".*/
create tk-kod. tk-kod.ps = "p". tk-kod.rez = "1". tk-kod.kod = 212151. tk-kod.knp = GetKNP("610,620,630,640,650,660"). /*"610,621,623,629,631,633,639,641,642,645,647,648,649,651,652,655,657,658,661,662,663".*/
create tk-kod. tk-kod.ps = "p". tk-kod.rez = "2". tk-kod.kod = 212152. tk-kod.knp = GetKNP("510,520,530,540,550,560"). /*"510,521,522,529,531,532,539,541,542,543,544,545,548,549,551,552,553,554,555,558,559,561,562,563".*/
create tk-kod. tk-kod.ps = "p". tk-kod.rez = "2". tk-kod.kod = 212160. tk-kod.knp = GetKNP("110,120,140,170,180,190,290,390,490,590,690,780,790,880,890"). /*"111,112,119,120,140,171,172,181,182,190,290,311,312,314,319,390,490,590,690,780,790,880,890".*/
/*-----------------------------------*/

/*Снятие средств со счета клиента*/
create tk-kod. tk-kod.ps = "s". tk-kod.rez = "1". tk-kod.kod = 221110. tk-kod.knp = GetKNP("212,219,710,720,730,740"). /*"710,730,212,219,721,722,740".*/
create tk-kod. tk-kod.ps = "s". tk-kod.rez = "1". tk-kod.kod = 221120. tk-kod.knp = GetKNP("810,820,830,840,850,860,870"). /*"811,812,813,814,815,816,817,818,819,820,831,832,833,834,835,836,837,839,840,851,852,853,854,855,856,859,861,862,869,870".*/
create tk-kod. tk-kod.ps = "s". tk-kod.rez = "1". tk-kod.kod = 221130. tk-kod.knp = GetKNP("410,570,670"). /*"411,413,419,570,671,672".*/
create tk-kod. tk-kod.ps = "s". tk-kod.rez = "1". tk-kod.kod = 221141. tk-kod.knp = GetKNP("420,580,680"). /*"421,423,424,429,580,681,682".*/
create tk-kod. tk-kod.ps = "s". tk-kod.rez = "2". tk-kod.kod = 221142. tk-kod.knp = GetKNP("420,580,680"). /*"421,423,424,429,580,681,682".*/
create tk-kod. tk-kod.ps = "s". tk-kod.rez = "1". tk-kod.kod = 221151. tk-kod.knp = GetKNP("610,620,630,640,650,660"). /*"610,621,623,629,631,633,639,641,642,645,647,648,649,651,652,655,657,658,661,662,663".*/
create tk-kod. tk-kod.ps = "s". tk-kod.rez = "2". tk-kod.kod = 221152. tk-kod.knp = GetKNP("510,520,530,540,550,560"). /*"510,521,522,529,531,532,539,541,542,543,544,545,548,549,551,552,553,554,555,558,559,561,562,563".*/
create tk-kod. tk-kod.ps = "s". tk-kod.rez = "1". tk-kod.kod = 221160. tk-kod.knp = GetKNP("110,120,140,170,180,190,290,320,390,490,590,690,780,790,880,890"). /*"111,112,119,120,140,171,172,181,182,190,290,311,312,314,319,390,490,590,690,780,790,880,890".*/

create tk-kod. tk-kod.ps = "s". tk-kod.rez = "2". tk-kod.kod = 222110. tk-kod.knp = GetKNP("212,219,710,720,730,740"). /*"710,730,212,219,721,722,740".*/
create tk-kod. tk-kod.ps = "s". tk-kod.rez = "2". tk-kod.kod = 222120. tk-kod.knp = GetKNP("810,820,830,840,850,860,870"). /*"811,812,813,814,815,816,817,818,819,820,831,832,833,834,835,836,837,839,840,851,852,853,854,855,856,859,861,862,869,870".*/
create tk-kod. tk-kod.ps = "s". tk-kod.rez = "2". tk-kod.kod = 222130. tk-kod.knp = GetKNP("410,570,670"). /*"411,413,419,570,671,672".*/
create tk-kod. tk-kod.ps = "s". tk-kod.rez = "1". tk-kod.kod = 222141. tk-kod.knp = GetKNP("420,580,680"). /*"421,423,424,429,580,681,682 ".*/
create tk-kod. tk-kod.ps = "s". tk-kod.rez = "2". tk-kod.kod = 222142. tk-kod.knp = GetKNP("420,580,680"). /*"421,423,424,429,580,681,682 ".*/
create tk-kod. tk-kod.ps = "s". tk-kod.rez = "2". tk-kod.kod = 222160. tk-kod.knp = GetKNP("110,120,140,170,180,190,290,390,490,590,690,780,790,880,890"). /*"111,112,119,120,140,171,172,181,182,190,290,311,312,314,319,390,490,590,690,780,790,880,890".*/
/*-------------------------------*/

/*Поступление средств на счет клиента*/
create tk-kod. tk-kod.ps = "n". tk-kod.rez = "1". tk-kod.kod = 210301. tk-kod.knp = GetKNP("130,321,312,314"). /*"131,132,311,312,314".*/
create tk-kod. tk-kod.ps = "n". tk-kod.rez = "2". tk-kod.kod = 210302. tk-kod.knp = GetKNP("130,321,312,314"). /*"131,132,311,312,314".*/
create tk-kod. tk-kod.ps = "n". tk-kod.kod = 210400. tk-kod.knp = GetKNP("211,213").
create tk-kod. tk-kod.ps = "n". tk-kod.kod = 210500. tk-kod.knp = GetKNP("311,312,314"). /*"311,312,314,319".*/

/*Снятие средств со счета клиента*/
create tk-kod. tk-kod.ps = "m". tk-kod.rez = "1". tk-kod.kod = 222151. tk-kod.knp = GetKNP("610,620,630,640,650,660"). /*"610,621,623,629,631,633,639,641,642,645,647,648,649,651,652,655,657,658,661,662,663".*/
create tk-kod. tk-kod.ps = "m". tk-kod.rez = "2". tk-kod.kod = 222152. tk-kod.knp = GetKNP("510,520,530,540,550,560"). /*"510,521,522,529,531,532,539,541,542,543,544,545,548,549,551,552,553,554,555,558,559,561,562,563".*/
create tk-kod. tk-kod.ps = "m". tk-kod.rez = "1". tk-kod.kod = 220301. tk-kod.knp = GetKNP("130"). /*GetKNP("130,321,322,324"). "131,132,321,322,324".*/
create tk-kod. tk-kod.ps = "m". tk-kod.rez = "2". tk-kod.kod = 220302. tk-kod.knp = GetKNP("130"). /*GetKNP("130,321,322,324"). "131,132,321,322,324".*/
create tk-kod. tk-kod.ps = "m". tk-kod.kod = 220400. tk-kod.knp = GetKNP("221,223").
create tk-kod. tk-kod.ps = "m". tk-kod.kod = 220500. tk-kod.knp = GetKNP("321,322,324"). /*"321,322,324,329".*/

/*Общий список кодов строк*/
create t1. t1.kod = 100000. t1.name = "Остаток на начало периода".
create t1. t1.kod = 210000. t1.name = "Поступление на банковские счета клиентов в иностранной валюте, всего" .
create t1. t1.kod = 211000. t1.name = "Резидентов".
create t1. t1.kod = 211110. t1.name = "Продажа товаров и нематериальных активов".
create t1. t1.kod = 211120. t1.name = "предоставление услуг".
create t1. t1.kod = 211130. t1.name = "получение основной суммы долга и доходов по выданным займам".
create t1. t1.kod = 211140. t1.name = "привлечение займов".
create t1. t1.kod = 211141. t1.name = "банков-резидентов".
create t1. t1.kod = 211142. t1.name = "банков-нерезидентов".
create t1. t1.kod = 211150. t1.name = "операции с ценными бумагами, векселями и взносы, обеспечивающие участие в капитале".
create t1. t1.kod = 211151. t1.name = "Резидентов".
create t1. t1.kod = 211152. t1.name = "Нерезидентов".
create t1. t1.kod = 211160. t1.name = "прочие переводы денег".
create t1. t1.kod = 212000. t1.name = "Нерезидентов".
create t1. t1.kod = 212110. t1.name = "продажа товаров и нематериальных активов".
create t1. t1.kod = 212120. t1.name = "предоставление услуг".
create t1. t1.kod = 212130. t1.name = "получение основной суммы долга и доходов по выданным займам ".
create t1. t1.kod = 212140. t1.name = "привлечение займов".
create t1. t1.kod = 212141. t1.name = "банков-резидентов".
create t1. t1.kod = 212142. t1.name = "банков-нерезидентов".
create t1. t1.kod = 212150. t1.name = "операции с ценными бумагами, векселями и взносы, обеспечивающие участие в капитале".
create t1. t1.kod = 212151. t1.name = "Резидентов".
create t1. t1.kod = 212152. t1.name = "Нерезидентов".
create t1. t1.kod = 212160. t1.name = "прочие переводы денег".
create t1. t1.kod = 210300. t1.name = "Переводы клиентами денег со своих банковских счетов".
create t1. t1.kod = 210301. t1.name = "банках-резидентах".
create t1. t1.kod = 210302. t1.name = "банках-нерезидентах".
create t1. t1.kod = 210400. t1.name = "Покупка иностранной валюты за тенге".
create t1. t1.kod = 210500. t1.name = "Зачисление наличной иностранной валюты на свои банковские счета".
create t1. t1.kod = 220000. t1.name = "Списание денег с банковских счетов клиентов в иностранной валюте, всего".
create t1. t1.kod = 221000. t1.name = "Резидентов".
create t1. t1.kod = 221110. t1.name = "покупка товаров и нематериальных активов".
create t1. t1.kod = 221120. t1.name = "получение услуг".
create t1. t1.kod = 221130. t1.name = "выдача займов".
create t1. t1.kod = 221140. t1.name = "выполнение обязательств по займам".
create t1. t1.kod = 221141. t1.name = "банков-резидентов".
create t1. t1.kod = 221142. t1.name = "банков-нерезидентов".
create t1. t1.kod = 221150. t1.name = "операции с ценными бумагами, векселями и взносы, обеспечивающие участие в капитале".
create t1. t1.kod = 221151. t1.name = "Резидентов".
create t1. t1.kod = 221152. t1.name = "Нерезидентов".
create t1. t1.kod = 221160. t1.name = "прочие переводы денег".
create t1. t1.kod = 222000. t1.name = "Нерезидентов".
create t1. t1.kod = 222110. t1.name = "покупка товаров и нематериальных активов".
create t1. t1.kod = 222120. t1.name = "получение услуг".
create t1. t1.kod = 222130. t1.name = "выдача займов".
create t1. t1.kod = 222140. t1.name = "выполнение обязательств по займам".
create t1. t1.kod = 222141. t1.name = "банков-резидентов".
create t1. t1.kod = 222142. t1.name = "банков-нерезидентов".
create t1. t1.kod = 222150. t1.name = "операции с ценными бумагами, векселями и взносы, обеспечивающие участие в капитале".
create t1. t1.kod = 222151. t1.name = "Резидентов".
create t1. t1.kod = 222152. t1.name = "нерезидентов".
create t1. t1.kod = 222160. t1.name = "прочие переводы денег".
create t1. t1.kod = 220300. t1.name = "Переводы клиентами денег на свои банковские  счета".
create t1. t1.kod = 220301. t1.name = "банках-резидентах".
create t1. t1.kod = 220302. t1.name = "банках-нерезидентах".
create t1. t1.kod = 220400. t1.name = "Продажа иностранной валюты за тенге".
create t1. t1.kod = 220500. t1.name = "Списание наличной иностранной валюты со своих банковских счетов".
create t1. t1.kod = 300000. t1.name = "Остаток на конец периода".
create t1. t1.kod = 410400. t1.name = "Покупка иностранной валюты (в том числе за другую иностранную валюту), всего".
create t1. t1.kod = 412400. t1.name = "в том числе для осуществления платежей и переводов в пользу нерезидентов".
create t1. t1.kod = 420400. t1.name = "Продажа иностранной валюты (в том числе за другую иностранную валюту), всего".
create t1. t1.kod = 420408. t1.name = "в том числе обратная продажа неиспользованной купленной иностранной валюты".
/*------------------------*/

output to value(file).

{html-title.i}

put unformatted
    "<HTML xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns="""">" skip
    "<HEAD>"                                       skip
    " <!--[if gte mso 9]><xml>"                       skip
    " <x:ExcelWorkbook>"                              skip
    " <x:ExcelWorksheets>"                            skip
    " <x:ExcelWorksheet>"                             skip
    " <x:Name>17161</x:Name>"                         skip
    " <x:WorksheetOptions>"                           skip
    " <x:Zoom>70</x:Zoom>"                            skip
    " <x:Selected/>"                                  skip
    " <x:DoNotDisplayGridlines/>"                     skip
    " <x:TopRowVisible>52</x:TopRowVisible>"          skip
    " <x:Panes>"                                      skip
    " <x:Pane>"                                       skip
    " <x:Number>3</x:Number>"                         skip
    " <x:ActiveRow>12</x:ActiveRow>"                  skip
    " <x:ActiveCol>24</x:ActiveCol>"                  skip
    " </x:Pane>"                                      skip
    " </x:Panes>"                                     skip
    " <x:ProtectContents>False</x:ProtectContents>"   skip
    " <x:ProtectObjects>False</x:ProtectObjects>"     skip
    " <x:ProtectScenarios>False</x:ProtectScenarios>" skip
    " </x:WorksheetOptions>"                          skip
    " </x:ExcelWorksheet>"                            skip
    " </x:ExcelWorksheets>"                           skip
    " <x:WindowHeight>7305</x:WindowHeight>"          skip
    " <x:WindowWidth>14220</x:WindowWidth>"           skip
    " <x:WindowTopX>120</x:WindowTopX>"               skip
    " <x:WindowTopY>30</x:WindowTopY>"                skip
    " <x:ProtectStructure>False</x:ProtectStructure>" skip
    " <x:ProtectWindows>False</x:ProtectWindows>"     skip
    " </x:ExcelWorkbook>"                             skip
    "</xml><![endif]-->"                              skip
    "<meta http-equiv=Content-Language content=ru>"   skip.

put unformatted
    "<P align=""center"" style=""font:bold;font-size:small"">Форма 3. Отчет о движении денег на банковских счетах клиентов в иностранной валюте c " vn-dtbeg " по " vn-dt "<BR>" skip.
put unformatted
    "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.

put unformatted
    "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
    "<TD></TD>"     skip
    "<TD>" txb.cif.name "</TD>" skip
    "<TD></TD>"     skip
    "<TD></TD>"     skip
    "<TD></TD>"     skip
    "<TD></TD>"     skip.

for each tk-aaa no-lock:
    put unformatted
        "<TD></TD>"
        "<TD></TD>"
        "<TD></TD>".
end.

put unformatted
    "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
    "<TD></TD>"     skip
    "<TD>ОКПО</TD>" skip
    "<TD></TD>"     skip
    "<TD></TD>"     skip
    "<TD></TD>"     skip
    "<TD></TD>"     skip.

for each tk-aaa no-lock:
    put unformatted
        "<TD></TD>"
        "<TD></TD>"
        "<TD></TD>".
end.

put unformatted
    "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
    "<TD></TD>"      skip
    "<TD>" txb.cif.jss "</TD>"   skip
    "<TD></TD>"      skip
    "<TD colspan = 3>Всего </TD>" skip.

for each tk-aaa no-lock:
    put unformatted "<TD colspan = 3>'" tk-aaa.aaa "</TD>"  .
end.

put unformatted
    "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite "">" skip
    "<TD>N</TD>"                       skip
    "<TD>Наименование показателя</TD>" skip
    "<TD>Код строки</TD>"              skip
    "<TD>USD</TD>"                     skip
    "<TD>EUR</TD>"                     skip
    "<TD>RUR</TD>"                     skip.

for each tk-aaa no-lock:
    put unformatted
        "<TD>USD</TD>" skip
        "<TD>EUR</TD>" skip
        "<TD>RUR</TD>" skip.
end.

for each tk-aaa no-lock:
    v-dam = 0. v-cam = 0.
    for each txb.jl where txb.jl.acc = tk-aaa.aaa and txb.jl.jdt >= vn-dtbeg and txb.jl.jdt <= vn-dt no-lock use-index acc by txb.jl.jh:
        find txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.

        s-jh = txb.jh.jh.
        v-storned = false. v-KOd = "". v-KBe = "". v-KNP = "". v-naznplat = "". z_knp = "". z_rez = "".

        v-storned = txb.jl.rem[1] matches "*Storn*" or txb.jl.rem[2] matches "*Storn*" or txb.jl.rem[3] matches "*Storn*" or
        txb.jl.rem[4] matches "*Storn*" or txb.jl.rem[5] matches "*Storn*".

        v-naznplat = txb.jl.rem[1] + " . " + txb.jl.rem[2] + " . " + txb.jl.rem[3] + " . " + txb.jl.rem[4] + " . " + txb.jl.rem[5].

        if trim(txb.jh.party) begins "rmz" or trim(txb.jh.party) begins "jou" then do:
            find first txb.sub-cod where txb.sub-cod.acc = substr(trim(txb.jh.party),1,10) and
            txb.sub-cod.sub = substr(trim(txb.jh.party),1,3) and txb.sub-cod.d-cod = "eknp" no-lock no-error.
            if avail txb.sub-cod then do:
                v-KOd = substr(txb.sub-cod.rcode,1,2).
                v-KBe = substr(txb.sub-cod.rcode,4,2).
                v-KNP = substr(txb.sub-cod.rcode,7,3).
            end.
        end.

        if txb.jl.dam = 0 then do:
            v-cam = v-cam + txb.jl.cam.
            find last txb.trgt where txb.trgt.jh = txb.jl.jh no-lock no-error.
            if avail txb.trgt then do:
                for each t1 break by t1.kod:
                    if t1.kod = 410400 then do:
                        find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
                        if not avail t2 then
                        create t2.
                        t2.kod = t1.kod.
                        t2.aaa = tk-aaa.aaa.
                        if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.cam / 1000, 2).
                        if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.cam / 1000, 2).
                        if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.cam / 1000, 2).
                    end.

                    if trgt.rem1 = "Осуществление платежей в пользу нерезидентов" then do:
                        if t1.kod = 412400 then do:
                            find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
                            if not avail t2 then
                            create t2.
                            t2.kod = t1.kod.
                            t2.aaa = tk-aaa.aaa.
                            if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.cam / 1000, 2).
                            if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.cam / 1000, 2).
                            if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.cam / 1000, 2).
                        end.
                    end.
                end.
            end.

            if v-KOd + v-KBe + v-KNP = "" then do:
                run GetCods_txb(v-storned,s-jh,txb.jl.dc,txb.jl.cam,txb.jl.acc,output v-KOd,output v-KBe,output v-KNP).
            end.

            if v-KOd + v-KBe + v-KNP <> "" then do:
                z_rez = substr(v-KOd,1,1).
                z_knp = v-KNP.
            end.
            else do:
                z_rez = "not found".
                z_knp = "not found".
            end.

            if z_rez = "1" then do: /*резидент*/
                for each t1 break by t1.kod:
                    find last tk-kod where tk-kod.kod = t1.kod and tk-kod.ps = "p" and tk-kod.rez = "1" no-lock no-error.
                    if avail tk-kod then do:
                        if z_knp <> "" and lookup(trim(z_knp),tk-kod.knp) > 0 then do:
                            find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
                            if not avail t2 then
                            create t2.
                            t2.kod = t1.kod.
                            t2.aaa = tk-aaa.aaa.

                            if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.cam / 1000, 2).
                            if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.cam / 1000, 2).
                            if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.cam / 1000, 2).
                        end.
                    end.
                    else do:
                        find last tk-kod where tk-kod.kod = t1.kod and tk-kod.ps = "n" and tk-kod.rez = "1" no-lock no-error.
                        if avail tk-kod then do:
                            if z_knp <> "" and lookup(trim(z_knp),tk-kod.knp) > 0 then do:
                                find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
                                if not avail t2 then
                                create t2.
                                t2.kod = t1.kod.
                                t2.aaa = tk-aaa.aaa.

                                if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.cam / 1000, 2).
                                if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.cam / 1000, 2).
                                if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.cam / 1000, 2).
                            end.
                        end.
                    end.
                end.
            end. /*if z_rez = "1"*/
            else if z_rez = "2" then do: /*нерезидент*/
                for each t1 break by t1.kod:
                    find last tk-kod where tk-kod.kod = t1.kod and tk-kod.ps = "p" and tk-kod.rez = "2" no-lock no-error.
                    if avail tk-kod then do:
                        if z_knp <> "" and lookup(z_knp, tk-kod.knp) > 0 then do:
                            find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
                            if not avail t2 then
                            create t2.
                            t2.kod = t1.kod.
                            t2.aaa = tk-aaa.aaa.

                            if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.cam / 1000, 2).
                            if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.cam / 1000, 2).
                            if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.cam / 1000, 2).
                        end.
                    end.
                    else do:
                        find last tk-kod where tk-kod.kod = t1.kod and tk-kod.ps = "n" and tk-kod.rez = "2" no-lock no-error.
                        if avail tk-kod then do:
                            if z_knp <> "" and lookup(trim(z_knp),tk-kod.knp) > 0 then do:
                                find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
                                if not avail t2 then
                                create t2.
                                t2.kod = t1.kod.
                                t2.aaa = tk-aaa.aaa.

                                if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.cam / 1000, 2).
                                if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.cam / 1000, 2).
                                if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.cam / 1000, 2).
                            end.
                        end.
                    end.
                end.
            end. /*if z_rez = "2"*/
            else if z_rez = "not found" then do: /*признак резидентства не найден*/
                find last tk-kod where tk-kod.kod = t1.kod and tk-kod.ps = "n" and tk-kod.rez <> "1" and tk-kod.rez <> "2" no-lock no-error.
                if avail tk-kod then do:
                    if z_knp <> "" and lookup(trim(z_knp),tk-kod.knp) > 0 then do:
                        find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
                        if not avail t2 then
                        create t2.
                        t2.kod = t1.kod.
                        t2.aaa = tk-aaa.aaa.

                        if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.cam / 1000, 2).
                        if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.cam / 1000, 2).
                        if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.cam / 1000, 2).
                    end.
                end.
            end.
        end. /*if txb.jl.dam = 0*/

        if txb.jl.cam = 0 then do:
            v-dam = v-dam + txb.jl.dam.
            find last txb.trgt where txb.trgt.jh = txb.jl.jh no-lock no-error.
            if avail txb.trgt then do:
                for each t1 break by t1.kod:
                    if t1.kod = 420400 then do:
                        find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
                        if not avail t2 then
                        create t2.
                        t2.kod = t1.kod.
                        t2.aaa = tk-aaa.aaa.
                        if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.dam / 1000, 2).
                        if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.dam / 1000, 2).
                        if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.dam / 1000, 2).
                    end.

                    if trgt.rem1 = "Осуществление платежей в пользу нерезидентов" then do:
                        if t1.kod = 420408 then do:
                            find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
                            if not avail t2 then
                            create t2.
                            t2.kod = t1.kod.
                            t2.aaa = tk-aaa.aaa.
                            if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.dam / 1000, 2).
                            if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.dam / 1000, 2).
                            if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.dam / 1000, 2).
                        end.
                    end.
                end.
            end.

            if v-KOd + v-KBe + v-KNP = "" then do:
                run GetCods_txb(v-storned,s-jh,txb.jl.dc,txb.jl.dam,txb.jl.acc,output v-KOd,output v-KBe,output v-KNP).
            end.

            if v-KOd + v-KBe + v-KNP <> "" then do:
                z_rez = substr(v-KBe,1,1).
                z_knp = v-KNP.
            end.
            else do:
                z_rez = "not found".
                z_knp = "not found".
            end.

            if z_rez = "1" then do:  /*резидент*/
                for each t1 break by t1.kod:
                    find last tk-kod where tk-kod.kod = t1.kod and tk-kod.ps = "s" and tk-kod.rez = "1" no-lock no-error.
                    if avail tk-kod then do:
                        if z_knp <> "" and lookup(z_knp, tk-kod.knp) > 0 then do:
                            v-addanother = false.
                            run addanother(tk-kod.kod,txb.jl.dam).

                            if not v-addanother then do:
                                find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
                                if not avail t2 then
                                create t2.
                                t2.kod = t1.kod.
                                t2.aaa = tk-aaa.aaa.

                                if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.dam / 1000, 2).
                                if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.dam / 1000, 2).
                                if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.dam / 1000, 2).
                            end.
                        end.
                    end.
                    else do:
                        find last tk-kod where tk-kod.kod = t1.kod and tk-kod.ps = "m" and tk-kod.rez = "1" no-lock no-error.
                        if avail tk-kod then do:
                            if z_knp <> "" and lookup(trim(z_knp),tk-kod.knp) > 0 then do:
                                find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
                                if not avail t2 then
                                create t2.
                                t2.kod = t1.kod.
                                t2.aaa = tk-aaa.aaa.

                                if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.dam / 1000, 2).
                                if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.dam / 1000, 2).
                                if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.dam / 1000, 2).
                            end.
                        end.
                    end.
                end.
            end. /*if z_rez = "1"*/
            else if z_rez = "2" then do: /*нерезидент*/
                for each t1 break by t1.kod:
                    find last tk-kod where tk-kod.kod = t1.kod and tk-kod.ps = "s" and tk-kod.rez = "2" no-lock no-error.
                    if avail tk-kod then do:
                        if z_knp <> "" and lookup(z_knp, tk-kod.knp) <> 0 then do:
                            v-addanother = false.
                            run addanother(tk-kod.kod,txb.jl.dam).

                            if not v-addanother then do:
                                find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
                                if not avail t2 then
                                create t2.
                                t2.kod = t1.kod.
                                t2.aaa = tk-aaa.aaa.

                                if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.dam / 1000, 2).
                                if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.dam / 1000, 2).
                                if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.dam / 1000, 2).
                            end.
                        end.
                    end.
                    else do:
                        find last tk-kod where tk-kod.kod = t1.kod and tk-kod.ps = "m" and tk-kod.rez = "2" no-lock no-error.
                        if avail tk-kod then do:
                            if z_knp <> "" and lookup(trim(z_knp),tk-kod.knp) > 0 then do:
                                find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
                                if not avail t2 then
                                create t2.
                                t2.kod = t1.kod.
                                t2.aaa = tk-aaa.aaa.

                                if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.dam / 1000, 2).
                                if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.dam / 1000, 2).
                                if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.dam / 1000, 2).
                            end.
                        end.
                    end.
                end.
            end. /*if z_rez = "2"*/
            else if z_rez = "not found" then do: /*признак резидентства не найден*/
                find last tk-kod where tk-kod.kod = t1.kod and tk-kod.ps = "m" and tk-kod.rez <> "1" and tk-kod.rez <> "2" no-lock no-error.
                if avail tk-kod then do:
                    if z_knp <> "" and lookup(trim(z_knp),tk-kod.knp) > 0 then do:
                        find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
                        if not avail t2 then
                        create t2.
                        t2.kod = t1.kod.
                        t2.aaa = tk-aaa.aaa.

                        if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.dam / 1000, 2).
                        if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.dam / 1000, 2).
                        if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.dam / 1000, 2).
                    end.
                end.
            end.

            if z_knp = "not found" then do: /*КНП не найден*/
                if v-naznplat matches "*плата по аккредитиву*" then do:
                    find last t2 where t2.kod = 220301 and t2.aaa = tk-aaa.aaa no-error.
                    if not avail t2 then
                    create t2.
                    t2.kod = 220301.
                    t2.aaa = tk-aaa.aaa.

                    if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.dam / 1000, 2).
                    if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.dam / 1000, 2).
                    if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.dam / 1000, 2).
                end.
                else if v-naznplat matches "*профсоюзные/членские взносы*" then do:
                    find last t2 where t2.kod = 222160 and t2.aaa = tk-aaa.aaa no-error.
                    if not avail t2 then
                    create t2.
                    t2.kod = 222160.
                    t2.aaa = tk-aaa.aaa.

                    if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.dam / 1000, 2).
                    if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.dam / 1000, 2).
                    if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.dam / 1000, 2).
                end.
                else if v-naznplat matches "*выплата по чеку*" then do:
                    find last t2 where t2.kod = 220500 and t2.aaa = tk-aaa.aaa no-error.
                    if not avail t2 then
                    create t2.
                    t2.kod = 220500.
                    t2.aaa = tk-aaa.aaa.

                    if tk-aaa.crc = 2 then t2.usd = t2.usd + round(txb.jl.dam / 1000, 2).
                    if tk-aaa.crc = 3 then t2.eur = t2.eur + round(txb.jl.dam / 1000, 2).
                    if tk-aaa.crc = 4 then t2.rur = t2.rur + round(txb.jl.dam / 1000, 2).
                end.
            end.
        end.

        do transaction:
            create t-rash_2.
            t-rash_2.txb = v-ourbnk.
            t-rash_2.bnkname = v-filnam.
            t-rash_2.cifname = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
            find txb.remtrz where txb.remtrz.remtrz = substr(trim(txb.jh.party),1,10) no-lock no-error.
            if avail txb.remtrz then do:
                t-rash_2.dtdoc = txb.remtrz.rdt.
                t-rash_2.rmz = txb.remtrz.remtrz.
                t-rash_2.benbank = txb.remtrz.bb[2].
                t-rash_2.ordbank = txb.remtrz.ordins[2].

                if txb.jl.dc = "D" then do:
                    t-rash_2.swiftben = txb.remtrz.rbank.
                    t-rash_2.swiftord = txb.remtrz.sbank.
                end.
                else do:
                    t-rash_2.swiftben = txb.remtrz.sbank.
                    t-rash_2.swiftord = txb.remtrz.rbank.
                end.
            end.
            else do:
                if avail txb.joudoc then do:
                    t-rash_2.dtdoc = txb.joudoc.whn.
                    t-rash_2.rmz = txb.joudoc.docnum.
                end.
                t-rash_2.benbank = 'АО "ForteBank"'.
                t-rash_2.swiftben = v-ourbnk.
                t-rash_2.ordbank = 'АО "ForteBank"'.
                t-rash_2.swiftord = v-ourbnk.
            end.
            t-rash_2.rem = v-naznplat.
            if txb.jl.dc = "D" then do:
                t-rash_2.drgl_4 = inte(substr(string(txb.jl.gl),1,4)) no-error.
                t-rash_2.drgl = txb.jl.gl.
                t-rash_2.dacc = txb.jl.acc.
                t-rash_2.dcrc = txb.jl.crc.
                t-rash_2.damcrc = txb.jl.dam.
                t-rash_2.damkzt = CRC2KZT(txb.jl.dam,txb.jl.crc,txb.jl.whn).
                find b1-crc where b1-crc.crc = t-rash_2.dcrc no-lock no-error.
                if avail b1-crc then t-rash_2.dcrccode = b1-crc.code.
            end.
            else do:
                t-rash_2.crgl_4 = inte(substr(string(txb.jl.gl),1,4)) no-error.
                t-rash_2.crgl = txb.jl.gl.
                t-rash_2.cacc = txb.jl.acc.
                t-rash_2.ccrc = txb.jl.crc.
                t-rash_2.camcrc = txb.jl.cam.
                t-rash_2.camkzt = CRC2KZT(txb.jl.cam,txb.jl.crc,txb.jl.whn).
                find b2-crc where b2-crc.crc = t-rash_2.ccrc no-lock no-error.
                if avail b2-crc then t-rash_2.ccrccode = b2-crc.code.
            end.
            t-rash_2.KOd = v-KOd.
            t-rash_2.KBe = v-KBe.
            t-rash_2.KNP = v-KNP.
        end.
    end. /*for each txb.jl*/

    do transaction:
        find txb.aaa where txb.aaa.aaa = tk-aaa.aaa no-lock no-error.
        find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.

        v-inbal = 0. v-outbal = 0.

        run lonbalcrc_txb("cif",txb.aaa.aaa,vn-dtbeg,"1",no,txb.aaa.crc,output v-inbal).
        run lonbalcrc_txb("cif",txb.aaa.aaa,vn-dt,"1",yes,txb.aaa.crc,output v-outbal).

        create t-rash_1.
        t-rash_1.txb = v-ourbnk.
        t-rash_1.bnkname = v-filnam.
        t-rash_1.cifname = trim(txb.cif.prefix) + " " + trim(txb.cif.name).
        t-rash_1.gl_4 = inte(substr(string(txb.aaa.gl),1,4)) no-error.
        t-rash_1.gl = txb.aaa.gl.
        t-rash_1.acc = txb.aaa.aaa.
        t-rash_1.crc = txb.aaa.crc.
        t-rash_1.bal_beg = - v-inbal.
        t-rash_1.dam = v-dam.
        t-rash_1.cam = v-cam.
        t-rash_1.bal_end = - v-outbal.
        find txb.crc where txb.crc.crc = t-rash_1.crc no-lock no-error.
        t-rash_1.crccode = txb.crc.code.
    end.
end. /*for each tk-aaa*/

/*Добавление недостающих кодов*/
for each t1 break by t1.kod:
    for each tk-aaa:
        find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
        if not avail t2 then do:
            create t2.
            t2.kod = t1.kod.
            t2.aaa = tk-aaa.aaa.
        end.
    end.
end.

/*Дополнительная обработка кодов*/
for each t1 break by t1.kod DESCENDING:
    if t1.kod = 100000 then do:
        for each tk-aaa:
            create t2.
            t2.kod = t1.kod.
            t2.aaa = tk-aaa.aaa.

            find last txb.histrxbal where txb.histrxbal.subled = "CIF" and txb.histrxbal.acc = tk-aaa.aaa and txb.histrxbal.level = 1 and
            txb.histrxbal.crc = tk-aaa.crc and txb.histrxbal.dt < vn-dtbeg no-lock no-error.
            if avail txb.histrxbal then do:
                if tk-aaa.crc = 2  then t2.usd = ABS(round((txb.histrxbal.dam - txb.histrxbal.cam) / 1000, 2)).
                if tk-aaa.crc = 3  then t2.eur = ABS(round((txb.histrxbal.dam - txb.histrxbal.cam) / 1000, 2)).
                if tk-aaa.crc = 4  then t2.rur = ABS(round((txb.histrxbal.dam - txb.histrxbal.cam) / 1000, 2)).
            end.
            else do:
                t2.usd = 0.
                t2.eur = 0.
                t2.rur = 0.
            end.
        end.
    end.

    if t1.kod = 210000 then do:
        for each tk-aaa:
            find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
            find last b1-t2 where b1-t2.kod = 211000 and b1-t2.aaa = tk-aaa.aaa no-error.
            find last b2-t2 where b2-t2.kod = 212000 and b2-t2.aaa = tk-aaa.aaa no-error.
            find last b3-t2 where b3-t2.kod = 210300 and b3-t2.aaa = tk-aaa.aaa no-error.
            find last b4-t2 where b4-t2.kod = 210400 and b4-t2.aaa = tk-aaa.aaa no-error.
            find last b5-t2 where b5-t2.kod = 210500 and b5-t2.aaa = tk-aaa.aaa no-error.

            t2.usd = b1-t2.usd + b2-t2.usd + b3-t2.usd + b4-t2.usd + b5-t2.usd.
            t2.eur = b1-t2.eur + b2-t2.eur + b3-t2.eur + b4-t2.eur + b5-t2.eur.
            t2.rur = b1-t2.rur + b2-t2.rur + b3-t2.rur + b4-t2.rur + b5-t2.rur.
        end.
    end.

    if t1.kod = 211000 then do:
        for each tk-aaa:
            find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
            find last b1-t2 where b1-t2.kod = 211110 and b1-t2.aaa = tk-aaa.aaa no-error.
            find last b2-t2 where b2-t2.kod = 211120 and b2-t2.aaa = tk-aaa.aaa no-error.
            find last b3-t2 where b3-t2.kod = 211130 and b3-t2.aaa = tk-aaa.aaa no-error.
            find last b4-t2 where b4-t2.kod = 211140 and b4-t2.aaa = tk-aaa.aaa no-error.
            find last b5-t2 where b5-t2.kod = 211150 and b5-t2.aaa = tk-aaa.aaa no-error.
            find last b6-t2 where b6-t2.kod = 211160 and b6-t2.aaa = tk-aaa.aaa no-error.

            t2.usd = b1-t2.usd + b2-t2.usd + b3-t2.usd + b4-t2.usd + b5-t2.usd + b6-t2.usd.
            t2.eur = b1-t2.eur + b2-t2.eur + b3-t2.eur + b4-t2.eur + b5-t2.eur + b6-t2.eur.
            t2.rur = b1-t2.rur + b2-t2.rur + b3-t2.rur + b4-t2.rur + b5-t2.rur + b6-t2.rur.
        end.
    end.

    if t1.kod = 211140 then do:
        for each tk-aaa:
            find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
            find last b1-t2 where b1-t2.kod = 211141 and b1-t2.aaa = tk-aaa.aaa no-error.
            find last b2-t2 where b2-t2.kod = 211142 and b2-t2.aaa = tk-aaa.aaa no-error.

            t2.usd = b1-t2.usd + b2-t2.usd.
            t2.eur = b1-t2.eur + b2-t2.eur.
            t2.rur = b1-t2.rur + b2-t2.rur.
        end.
    end.

    if t1.kod = 212000 then do:
        for each tk-aaa:
            find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
            find last b1-t2 where b1-t2.kod = 212110 and b1-t2.aaa = tk-aaa.aaa no-error.
            find last b2-t2 where b2-t2.kod = 212120 and b2-t2.aaa = tk-aaa.aaa no-error.
            find last b3-t2 where b3-t2.kod = 212130 and b3-t2.aaa = tk-aaa.aaa no-error.
            find last b4-t2 where b4-t2.kod = 212140 and b4-t2.aaa = tk-aaa.aaa no-error.
            find last b5-t2 where b5-t2.kod = 212150 and b5-t2.aaa = tk-aaa.aaa no-error.
            find last b6-t2 where b6-t2.kod = 212160 and b6-t2.aaa = tk-aaa.aaa no-error.

            t2.usd = b1-t2.usd + b2-t2.usd + b3-t2.usd + b4-t2.usd + b5-t2.usd + b6-t2.usd.
            t2.eur = b1-t2.eur + b2-t2.eur + b3-t2.eur + b4-t2.eur + b5-t2.eur + b6-t2.eur.
            t2.rur = b1-t2.rur + b2-t2.rur + b3-t2.rur + b4-t2.rur + b5-t2.rur + b6-t2.rur.
        end.
    end.

    if t1.kod = 212140 then do:
        for each tk-aaa:
            find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
            find last b1-t2 where b1-t2.kod = 212141 and b1-t2.aaa = tk-aaa.aaa no-error.
            find last b2-t2 where b2-t2.kod = 212142 and b2-t2.aaa = tk-aaa.aaa no-error.

            t2.usd = b1-t2.usd + b2-t2.usd.
            t2.eur = b1-t2.eur + b2-t2.eur.
            t2.rur = b1-t2.rur + b2-t2.rur.
        end.
    end.

    if t1.kod = 220000 then do:
        for each tk-aaa:
            find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
            find last b1-t2 where b1-t2.kod = 221000 and b1-t2.aaa = tk-aaa.aaa no-error.
            find last b2-t2 where b2-t2.kod = 222000 and b2-t2.aaa = tk-aaa.aaa no-error.
            find last b3-t2 where b3-t2.kod = 220300 and b3-t2.aaa = tk-aaa.aaa no-error.
            find last b4-t2 where b4-t2.kod = 220400 and b4-t2.aaa = tk-aaa.aaa no-error.
            find last b5-t2 where b5-t2.kod = 220500 and b5-t2.aaa = tk-aaa.aaa no-error.

            t2.usd = b1-t2.usd + b2-t2.usd + b3-t2.usd + b4-t2.usd + b5-t2.usd.
            t2.eur = b1-t2.eur + b2-t2.eur + b3-t2.eur + b4-t2.eur + b5-t2.eur.
            t2.rur = b1-t2.rur + b2-t2.rur + b3-t2.rur + b4-t2.rur + b5-t2.rur.
        end.
    end.

    if t1.kod = 221000 then do:
        for each tk-aaa:
            find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
            find last b1-t2 where b1-t2.kod = 221110 and b1-t2.aaa = tk-aaa.aaa no-error.
            find last b2-t2 where b2-t2.kod = 221120 and b2-t2.aaa = tk-aaa.aaa no-error.
            find last b3-t2 where b3-t2.kod = 221130 and b3-t2.aaa = tk-aaa.aaa no-error.
            find last b4-t2 where b4-t2.kod = 221140 and b4-t2.aaa = tk-aaa.aaa no-error.
            find last b5-t2 where b5-t2.kod = 221150 and b5-t2.aaa = tk-aaa.aaa no-error.
            find last b6-t2 where b6-t2.kod = 221160 and b6-t2.aaa = tk-aaa.aaa no-error.

            t2.usd = b1-t2.usd + b2-t2.usd + b3-t2.usd + b4-t2.usd + b5-t2.usd + b6-t2.usd.
            t2.eur = b1-t2.eur + b2-t2.eur + b3-t2.eur + b4-t2.eur + b5-t2.eur + b6-t2.eur.
            t2.rur = b1-t2.rur + b2-t2.rur + b3-t2.rur + b4-t2.rur + b5-t2.rur + b6-t2.rur.
        end.
    end.

    if t1.kod = 222000  then do:
        for each tk-aaa:
            find last t2 where t2.kod = t1.kod and t2.aaa = tk-aaa.aaa no-error.
            find last b1-t2 where b1-t2.kod = 222110 and b1-t2.aaa = tk-aaa.aaa no-error.
            find last b2-t2 where b2-t2.kod = 222120 and b2-t2.aaa = tk-aaa.aaa no-error.
            find last b3-t2 where b3-t2.kod = 222130 and b3-t2.aaa = tk-aaa.aaa no-error.
            find last b4-t2 where b4-t2.kod = 222140 and b4-t2.aaa = tk-aaa.aaa no-error.
            find last b5-t2 where b5-t2.kod = 222150 and b5-t2.aaa = tk-aaa.aaa no-error.
            find last b6-t2 where b6-t2.kod = 222160 and b6-t2.aaa = tk-aaa.aaa no-error.

            t2.usd = b1-t2.usd + b2-t2.usd + b3-t2.usd + b4-t2.usd + b5-t2.usd + b6-t2.usd.
            t2.eur = b1-t2.eur + b2-t2.eur + b3-t2.eur + b4-t2.eur + b5-t2.eur + b6-t2.eur.
            t2.rur = b1-t2.rur + b2-t2.rur + b3-t2.rur + b4-t2.rur + b5-t2.rur + b6-t2.rur.
        end.
    end.

    if t1.kod = 300000 then do:
        for each tk-aaa:
            create t2.
            t2.kod = t1.kod.
            t2.aaa = tk-aaa.aaa.
            find last txb.histrxbal where txb.histrxbal.subled = "CIF" and txb.histrxbal.acc = tk-aaa.aaa and txb.histrxbal.level = 1 and
            txb.histrxbal.crc = tk-aaa.crc and txb.histrxbal.dt <= vn-dt no-lock no-error.
            if avail txb.histrxbal then do:
                if tk-aaa.crc = 2  then t2.usd = ABS(round((txb.histrxbal.dam - txb.histrxbal.cam) / 1000, 2)).
                if tk-aaa.crc = 3  then t2.eur = ABS(round((txb.histrxbal.dam - txb.histrxbal.cam) / 1000, 2)).
                if tk-aaa.crc = 4  then t2.rur = ABS(round((txb.histrxbal.dam - txb.histrxbal.cam) / 1000, 2)).
            end.
            else do:
                t2.usd = 0.
                t2.eur = 0.
                t2.rur = 0.
            end.
        end.
    end.
end.

v-codd = "211150,212150,210300,221150,222150,220300".
v-cod1 = "211151,212151,210301,221151,222151,220301".
v-cod2 = "211152,212152,210302,221152,222152,220302".

do d-codd = 1 to 6:
    for each tk-aaa:
        find last t2 where t2.kod = integer(ENTRY(d-codd, v-codd)) and t2.aaa = tk-aaa.aaa no-error.
        find last b1-t2 where b1-t2.kod = integer(ENTRY(d-codd, v-cod1)) and b1-t2.aaa = tk-aaa.aaa no-error.
        find last b2-t2 where b2-t2.kod = integer(ENTRY(d-codd, v-cod2)) and b2-t2.aaa = tk-aaa.aaa no-error.
        t2.usd = b1-t2.usd + b2-t2.usd.
        t2.eur = b1-t2.eur + b2-t2.eur.
        t2.rur = b1-t2.rur + b2-t2.rur.
    end.
end.

/*Вывод данных в отчет*/
for each t1 break by t1.kod:
    i_tkod = t1.kod.

    run paintthml.
end.

{html-end.i}

output close.

unix silent cptwin value(file) excel.

procedure paintthml.
    ix = ix + 1.
    find last bt-t1 where bt-t1.kod = i_tkod no-lock no-error.
    put unformatted
        "<TR align=""center"" style=""font:bold;font-size:x-small;background:ghostwhite"">" skip
        "<TD>" ix "</TD>" skip
        "<TD>" bt-t1.name "</TD>" skip
        "<TD>" i_tkod "</TD>" skip.

    d-usd = 0. d-eur = 0. d-rur = 0.
    for each t2 where t2.kod = i_tkod no-lock:
        d-usd = d-usd + t2.usd.
        d-eur = d-eur + t2.eur.
        d-rur = d-rur + t2.rur.
    end.
    put unformatted
        "<TD>" replace(string(d-usd,"-zzzzzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
        "<TD>" replace(string(d-eur,"-zzzzzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
        "<TD>" replace(string(d-rur,"-zzzzzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.

    for each tk-aaa  no-lock:
        find last t2 where t2.aaa = tk-aaa.aaa and t2.kod = i_tkod no-lock no-error.
        if avail t2 then do:
            put unformatted
                "<TD>" replace(string(t2.usd,"-zzzzzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                "<TD>" replace(string(t2.eur,"-zzzzzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip
                "<TD>" replace(string(t2.rur,"-zzzzzzzzzzzzzzzzzzzzzzzz9.99"),".",",") "</TD>" skip.
        end.
        else do:
            put unformatted
                "<TD>0</TD>" skip
                "<TD>0</TD>" skip
                "<TD>0</TD>" skip.
        end.
    end.
end.

