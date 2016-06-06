/* vcdocsdiffcoll_txb.i
 * MODULE
        Название модуля - Валютный контроль
 * DESCRIPTION
        Описание - Сбор типов документов Валютного Контроля, используется совместно с vcdocsdifferent.i.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - vccomexpdat.p,vccomcreddat.p.
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
        25.12.2012 damir - Внедрено Т.З. № 1306.
*/

def var v-docsgtd as char.
def var v-docsplat as char.
def var v-docsakt as char.

v-docsgtd = "".
for each txb.codfr where txb.codfr.codfr = "vcdoc" and index("g",trim(txb.codfr.name[5])) > 0 no-lock:
    v-docsgtd = v-docsgtd + trim(txb.codfr.code) + ",".
end.

v-docsplat = "".
for each txb.codfr where txb.codfr.codfr = "vcdoc" and index("p",trim(txb.codfr.name[5])) > 0 no-lock:
    v-docsplat = v-docsplat + trim(txb.codfr.code) + ",".
end.

v-docsakt = "".
for each txb.codfr where txb.codfr.codfr = "vcdoc" and index("o",trim(txb.codfr.name[5])) > 0 and (trim(txb.codfr.code) = "17" or
trim(txb.codfr.code) = "07") no-lock:
    v-docsakt = v-docsakt + trim(txb.codfr.code) + ",".
end.


