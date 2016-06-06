/* GetCods.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        17.09.2012 damir - changing copy printGetEKNP.p, добавил input parameter p-ACC. Т.З. № 1379.
        17.07.2013 damir - Внедрено Т.З. № 1523.
*/

def input parameter  p-Storn as logi.
def input parameter  p-JH    as inte.
def input parameter  p-DC    as char.
def input parameter  p-SUM   as deci.
def input parameter  p-ACC   as char.
def output parameter p-KOd   as char.
def output parameter p-KBe   as char.
def output parameter p-KNP   as char.

def var KOd as char format "x(2)".
def var KBe as char format "x(2)".
def var KNP as char format "x(3)".
def var ln1 as inte.
def var ln2 as inte.
def var v-storned as logi.

def buffer ljl for jl.

find first jl where jl.jh = p-JH and jl.dc = p-DC and (jl.dam = p-SUM or jl.cam = p-SUM) and jl.crc <> 0 and jl.ln <> 0 no-lock no-error.
if avail jl and jl.acc = p-ACC then do:
    v-storned = false.
    if (jl.rem[1] matches "*Storn*" or jl.rem[2] matches "*Storn*" or jl.rem[3] matches "*Storn*" or jl.rem[4] matches "*Storn*" or jl.rem[5] matches "*Storn*") then v-storned = yes.

    ln1 = 0. ln2 = 0.
    if jl.dc = "D" then do:
        if v-storned = no then do: ln1 = jl.ln. ln2 = ln1 + 1. end.
        else do: ln1 = jl.ln. ln2 = ln1 - 1. end.
    end.
    else do:
        if v-storned = no then do:
            if jl.rem[1] matches "*обмен валюты*" then do: ln2 = jl.ln - 2. ln1 = jl.ln - 3. end.
            else do: ln2 = jl.ln. ln1 = ln2 - 1. end.
        end.
        else do: ln1 = jl.ln. ln2 = ln1 + 1. end.
    end.
    p-KOd = "". p-KBe = "". p-KNP = "".
    run GetEKNPCASH(v-storned,jl.jh,ln1,ln2,output p-KOd,output p-KBe,output p-KNP).
end.

procedure GetEKNPCASH:
    def input parameter  v-storned as logi.
    def input parameter  p-jh    as inte.
    def input parameter  p-ln1   as inte.
    def input parameter  p-ln2   as inte.
    def output parameter p_KOd   as char.
    def output parameter p_KBe   as char.
    def output parameter p_KNP   as char.

    KOd = "". KBe = "". KNP = "".
    for each ljl where ljl.jh = p-jh and (ljl.ln = p-ln1 or ljl.ln = p-ln2) no-lock:
        if v-storned = no then run GetEKNP(ljl.jh, ljl.ln, ljl.dc, input-output KOd, input-output KBe, input-output KNP).
        else run GetEKNP_Storn(ljl.jh, ljl.ln, ljl.dc, input-output KOd, input-output KBe, input-output KNP).

        if KOd + KBe + KNP <> "" then do: p_KOd = KOd. p_KBe = KBe. p_KNP = KNP. end.
        if p_KBe = "" then p_KBe = KBe.
    end.
end.


