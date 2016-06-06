/* GetRnnRmz.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание - Получение РНН,ИИН/БИН,Наименования отправителя или получателя платежа.
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
        BANK
 * CHANGES
        19.01.2012 damir.
        28.01.2012 damir - Корректировки в функции GetRnnBenOrd.
*/
function GetRnnBenOrd returns char(input p-ordben as char).
    def var v-res as char.
    def var v-OrientWord as char.
    def var v-str as char extent 2.
    def var i as inte.
    def var j as inte.
    def var k as inte.
    def var s as inte.
    def var v-tmp as char extent 2.
    def var v-NumList as char.
    def var v-RnnBenOrd as logi.

    v-OrientWord = "RNN,INN".
    v-NumList = "0,1,2,3,4,5,6,7,8,9".
    p-ordben = trim(p-ordben).
    v-RnnBenOrd = false.

    v-res = "". v-tmp[2] = "".
    upper:
    repeat i = 1 to num-entries(v-OrientWord):
        v-str[1] = "".
        v-str[1] = entry(i,v-OrientWord).
        if index(p-ordben,v-str[1]) gt 0 then do:
            v-tmp[1] = "".
            v-tmp[1] = trim(substr(p-ordben,index(p-ordben,v-str[1]) + 3,length(p-ordben))).
            s = 0.
            outer:
            repeat j = 1 to length(v-tmp[1]):
                if lookup(substr(v-tmp[1],j,1),v-NumList) gt 0 then do:
                    v-RnnBenOrd = true.
                    v-tmp[2] = v-tmp[2] + substr(v-tmp[1],j,1).
                    s = s + 1.
                end.
                else if s ne 0 then leave upper.
            end.
        end.
    end.
    if not v-RnnBenOrd then do:
        if num-entries(p-ordben,"/") gt 2 then v-tmp[2] = trim(entry(3,p-ordben,"/")).
    end.
    repeat k = 1 to length(v-tmp[2]):
        if lookup(substr(v-tmp[2],k,1),v-NumList) eq 0 then v-tmp[2] = "".
    end.

    v-res = v-tmp[2].
    return v-res.
end function.

function GetNameBenOrd returns char(input p-ordben as char).
    def var v-res as char.
    def var v-OrientWord as char.
    def var v-str as char extent 2.
    def var i as inte.
    def var j as inte.
    def var k as inte.
    def var v-tmp as char extent 2.
    def var PunctToAvoid as char.
    def var v-NameBenOrd as logi.

    v-OrientWord = "RNN,INN".
    PunctToAvoid = "/".
    p-ordben = trim(p-ordben).
    v-NameBenOrd = false.

    v-res = "".
    upper:
    repeat i = 1 to num-entries(v-OrientWord):
        v-tmp[1] = "". v-str[1] = "".
        v-str[1] = entry(i,v-OrientWord).
        if index(p-ordben,v-str[1]) gt 0 then do:
            v-NameBenOrd = true.
            v-tmp[1] = trim(substr(p-ordben,1,index(p-ordben,v-str[1]) - 1)).
            leave upper.
        end.
    end.
    if not v-NameBenOrd then do:
        v-tmp[1] = entry(1,p-ordben,"/").
    end.
    repeat k = 1 to num-entries(PunctToAvoid):
        v-tmp[1] = replace(v-tmp[1],entry(k,PunctToAvoid),"").
    end.

    v-res = v-tmp[1].
    return v-res.
end function.

