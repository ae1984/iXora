/* LCok.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        отправка аккредитива на авторизацию
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        09/09/2010 galina
 * BASES
        BANK COMM
 * CHANGES
   23/12/2010 Vera   - изменился frame frlc (добавлено 3 новых поля)
   21/01/2011 id00810 - убрала фрейм, изменила присваиваемый статус на MD1
   08/02/2011 id00810 - убрала проверку валюты для счета комиссии ComAcc
   22/02/2011 id00810 - добавила обязательные поля TRNum, Insto730 для EXPG
   24/02/2011 id00810 - обязательные поля для EXLC
   20/05/2011 id00810 - для EXSBlC
   19/07/2011 id00810 - поле ComAcc необязательно для EXPG
   29/07/2011 id00810 - поле DepAcc обязательно для покрытого PG (c 01/08/2011)
   15/08/2011 id00810 - изменения в связи с MT720
   14/09/2011 id00810 - МТ720 для EXLC
   12/10/2011 id00810 - проверка реквизитов для ПКБ
   30/12/2011 id00810 - для DC
   17/01/2012 id00810 - добавлена новая переменная s-fmt
   08/02/2012 id00810 - для ODC
   06.03.2012 Lyubov  - "dc" изменила на "idc"
   13.07.2012 Lyubov  - добавила отправку писем для подтверждения MD2
   16.07.2012 Lyubov  - испрвила lc.sts на lc.lcsts
   09/08/2013 galina - ТЗ1886 убрала проверку на обязательность заполнения признака 1CByes

*/

{mainhead.i}

def shared var v-lcsts  as char.
def shared var s-lc     like LC.LC.
def shared var s-lcprod as char.
def shared var s-fmt    as char.
def shared var s-namef    as char.
/*тут проверка на заполнение всех необходимых полей */
def var v-mlist  as char no-undo.
def var v-mlist2 as char no-undo.
def var i        as int  no-undo.
/*def var v-fmt    as char no-undo.*/
def var v-mt720  as logi no-undo.
def var v-logsno as char no-undo init "no,n,нет,н,1".
def buffer b-lch for lch.

def var v-zag      as char no-undo.
def var v-event    as char no-undo.
def var v-str      as char no-undo.
def var v-maillist as char no-undo.

find first lc where lc.lc = s-lc no-lock no-error.
if not avail lc then return.

if s-lcprod = 'imlc' then do:
    if s-fmt = '720' then do:
        assign v-mlist = 'InstTo'
               v-mt720 = yes.
        for each codfr where codfr.codfr = 'MT720'
                        and  codfr.name[5] = 'M'
                        no-lock:
            v-mlist = v-mlist + ',' + codfr.name[3].
            if codfr.name[4] ne '' then v-mlist = v-mlist + ',' + codfr.name[4].
        end.
    end.
    else v-mlist = 'FormCred,DtExp,PlcExp,Applic,Benef,lcCrc,Amount,AdvBank,AvlWith,By,Confir,ComAcc,Cover,AppRule'.
end.
else
if s-lcprod = 'expg' then
v-mlist = 'BankRef,DtAdv,DtExp,Princ,lcCrc,Amount,Cover,TRNum,Insto730'.
else
if s-lcprod = 'exlc' or s-lcprod = 'exsblc' then do:

    if s-fmt <> '760' then do:
        find first lch where lch.lc = s-lc and lch.kritcode = 'Advby' no-lock no-error.
        if not avail lch or lch.value1 = '' then do:
            message 'The field "Advise by" must be completed!' view-as alert-box.
            return.
        end.
    end.

end.
else
if s-lcprod = 'pg' then do:
    v-mlist = 'AdvBank'.
    for each codfr where codfr.codfr = 'MT760'
                    and  codfr.name[5] = 'M'
                    no-lock:
        v-mlist = v-mlist + ',' + codfr.name[3].
        if codfr.name[4] ne '' then v-mlist = v-mlist + ',' + codfr.name[4].
    end.
end.
else
if s-lcprod = 'sblc' then do:
    if s-fmt = '700'  then v-mlist = 'FormCred,DtExp,PlcExp,Applic,Benef,lcCrc,Amount,AdvBank,AvlWith,By,Confir,ComAcc,Cover,AppRule'.
    else for each codfr where codfr.codfr = 'MT760'
                    and  codfr.name[5] = 'M'
                    no-lock:
        v-mlist = v-mlist + ',' + codfr.name[3].
        if codfr.name[4] ne '' then v-mlist = v-mlist + ',' + codfr.name[4].
    end.
    find first lch where lch.lc = s-lc and lch.kritcode = 'mt799' no-lock no-error.
    if avail lch and lch.value1 = 'yes' then v-mlist = v-mlist + ',TRNum,RRef,Narrat'.
end.
else if s-lcprod = 'idc' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'MT410' no-lock no-error.
    if avail lch and lookup(lch.value1,v-logsno) = 0 then do:
        for each codfr where codfr.codfr   = 'MT410'
                         and codfr.name[5] = 'M'
                         no-lock:
            if lookup(codfr.name[3],v-mlist) = 0 then do:
                v-mlist = v-mlist + codfr.name[3] + ',' .
                if codfr.name[4] ne '' then v-mlist = v-mlist + codfr.name[4] + ',' .
            end.
        end.
        v-mlist = v-mlist + 'RemBank,'.
    end.
    v-mlist = v-mlist + 'number'.
end.
/*if lc.lctype = 'i' and not v-mt720 and s-lcprod <> 'odc' then do:
     find first lch where lch.lc = s-lc and lch.kritcode = '1CByes' no-lock no-error.
        if not avail lch or lch.value1 = '' then do:
            message 'The field "1CB" must be completed!' view-as alert-box.
            return.
        end.
        if lch.value1 = '01' then v-mlist = v-mlist + ',1cbclas,1cbctype,1cbcval,1cbccrc'.
end.*/

find first lch where lch.lc = s-lc and lch.kritcode = 'Cover' no-lock no-error.
if avail lch and lch.value1 = '0' then do:
    v-mlist = v-mlist + ',CollAcc'.
    if s-lcprod = 'pg' then v-mlist = v-mlist + ',DepAcc'.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'ExAbout' no-lock no-error.
if avail lch and lch.value1 = '1' then v-mlist = v-mlist + ',PerAmt'.

find first lch where lch.lc = s-lc and lch.kritcode = 'By' no-lock no-error.
if avail lch then do:
    if lch.value1 = '2' then v-mlist = v-mlist + ',DefPayD'.
    if lch.value1 = '3' then v-mlist = v-mlist + ',DrfAt,Drawee'.
end.

/*message v-mlist. pause.*/
v-mlist2 = ''.
do i = 1 to num-entries(v-mlist):
    find first lch where lch.lc = s-lc and lch.kritcode = entry(i,v-mlist) no-lock no-error.
    if not avail lch or lch.value1 = '' or lch.value1 = ? then do:
        find first lckrit where lckrit.datacode = entry(i,v-mlist) no-lock no-error.
        if avail lckrit then do:
            if trim(v-mlist2) <> '' then v-mlist2 = v-mlist2 + ','.
            v-mlist2 = v-mlist2 + lckrit.dataName.
        end.
    end.
end.
if trim(v-mlist2) <> '' then do:
    message 'The following fields are compulsory to complete:~n~n"'  + v-mlist2 + '"' view-as alert-box.
    return.
end.

find first lch where lch.lc = s-lc and lch.kritcode = 'By' no-lock no-error.
if avail lch then do:
    v-mlist = ''.
    if lch.value1 <> '2' then do:
        find first b-lch where b-lch.lc = s-lc and b-lch.kritcode = 'DefPayD' no-lock no-error.
        if avail b-lch and trim(b-lch.value1) <> '' then do:
            find first lckrit where lckrit.datacode = 'DefPayD' no-lock no-error.
            if avail lckrit then  do:
                if v-mlist <> '' then v-mlist = v-mlist + ','.
                v-mlist = v-mlist + lckrit.dataName.
            end.
        end.

    end.
    if lch.value1 <> '3' then do:
        find first b-lch where b-lch.lc = s-lc and b-lch.kritcode = 'DrfAt' no-lock no-error.
        if avail b-lch and trim(b-lch.value1) <> '' then do:
            find first lckrit where lckrit.datacode = 'DrfAt' no-lock no-error.
            if avail lckrit then  do:
                if v-mlist <> '' then v-mlist = v-mlist + ','.
                v-mlist = v-mlist + lckrit.dataName.
            end.
        end.
        find first b-lch where b-lch.lc = s-lc and b-lch.kritcode = 'Drawee' no-lock no-error.
        if avail b-lch and trim(b-lch.value1) <> '' then do:
            find first lckrit where lckrit.datacode = 'Drawee' no-lock no-error.
            if avail lckrit then do:
                if v-mlist <> '' then v-mlist = v-mlist + ','.
                v-mlist = v-mlist + lckrit.dataName.
            end.
        end.
    end.
    if v-mlist <> '' then do:
       message 'The following fields must be empty:~n"' + v-mlist + '"' view-as alert-box.
       return.
    end.
end.
find first lch where lch.lc = s-lc and lch.kritcode = 'Cover' no-lock no-error.
if avail lch then if lch.value1 = '0' then do:
    find first lch where lch.lc = s-lc and lch.kritcode = 'Collacc' no-lock no-error.
    find first aaa where aaa.aaa = trim(lch.value1) no-lock no-error.
    find first lch where lch.lc = s-lc and lch.kritcode = 'lcCrc' no-lock no-error.
    if trim(lch.value1) <> string(aaa.crc) then do:
        message "The currency of Collateral Debit Account shoud be the same with Currency Code!" view-as alert-box.
        return.
    end.
end.

/*********************/
if v-lcsts  = 'NEW' then do:
    pause 0.
    run LCsts(v-lcsts,'MD1').
end.

find last lc where lc.lc = s-lc no-lock no-error.
if avail lc and lc.lcsts = 'MD1' then do:
v-event = if lc.lc begins 'EX' then 'Advise' else 'Create'.
  /* сообщение */
    find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'MD2-2' no-lock no-error.
    if avail bookcod then do:
        v-maillist = bookcod.name.
    end.
    if v-maillist <> '' then do:
        assign v-zag = 'MD2'
               v-str = 'You have a ' + v-event + ' under ' + s-lc + ' pending – filial ' + s-namef + '.'.
        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "1", "","").
    end.
end.