/* printordbks.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание - Контрольный чек БКС
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        23.05.2012 damir - добавил defprintbks.i.
*/
{global.i}
{get-dep.i} /*Номер департамента*/
{ndssvi.i}

def input parameter s_payment as char no-undo.
def input parameter s_trx     as char no-undo.

{ defprintbks.i }

def var s_depname       as char no-undo.
def var commonpl_rnnbn  as char no-undo.
def var commonls_bn     as char no-undo.
def var commonpl_rnn    as char no-undo.
def var commonpl_fioadr as char no-undo.
def var s_rnn           as char no-undo.
def var i_temp_dep      as inte no-undo.

s_trx           = entry(1,s_trx,'#') no-error.
commonpl_rnnbn  = entry(2,s_trx,'#') no-error.
commonls_bn     = entry(3,s_trx,'#') no-error.
commonpl_rnn    = entry(4,s_trx,'#') no-error.
commonpl_fioadr = entry(5,s_trx,'#') no-error.


d_bksnmb = entry(1,entry(1, s_payment, '|'),'#').
i_temp_dep = inte(get-dep(g-ofc, g-today)).
find first depaccnt where depaccnt.depart = i_temp_dep no-lock no-error.
if avail depaccnt and depaccnt.rem <> '' then do:
    find first cmp no-lock no-error.
    find first ppoint where ppoint.depart = depaccnt.depart no-lock no-error.
    if avail ppoint then s_depname = cmp.name + " " + ppoint.name.
    else s_depname = '***'.
    s_nknmb = entry(1,depaccnt.rem,'$').
    if entry(4,depaccnt.rem,'$') = "" then do:
        find first cmp no-lock no-error.
        s_rnn = cmp.addr[2].
    end.
    else s_rnn = entry(4,depaccnt.rem,'$').
end.
else do:
    s_nknmb = '***'.
end.
