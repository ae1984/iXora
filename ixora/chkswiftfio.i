/* chkswiftfio.i
 * MODULE
        Клиентские операции
 * DESCRIPTION
        Проверка фамилии
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        --/--/2013 yerganat
 * BASES
        BANK
 * CHANGES
        18.10.2013 yergant - TZ1750, функция проверки фамилии в swift файле
*/

function chkFIOsymbols returns logical (input p-string as char).
 def var v-engsimbols       as character initial  'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
 def var v-CAPengsimbols    as character initial  'abcdefghijklmnopqrstuvwxyz'.
 def var v-kazsimbols       as character initial  'ајбвгєдеёжзийкќлмнѕоґпрстуўїфхћцчшщъыіьэюя'.
 def var v-CAPkazsimbols    as character initial  'АЈБВГЄДЕЁЖЗИЙКЌЛМНЅОҐПРСТУЎЇФХЋЦЧШЩЪЫIЬЭЮЯ'.
 def var v-ADDsimbols       as character initial  ".,-' ".
 def var v-simbol           as character.
 def var v-idx              as int       initial  1.

 do while v-idx <= length(p-string):
    v-simbol = substring(p-string, v-idx, 1).
    if index(v-kazsimbols,v-simbol) = 0 then
        if index(v-CAPkazsimbols,v-simbol) = 0 then
            if index(v-ADDsimbols,v-simbol) = 0 then
                if index(v-engsimbols,v-simbol) = 0 then
                    if index(v-CAPengsimbols,v-simbol) = 0 then
                        return no.

    v-idx = v-idx + 1.
 end.
 return yes.
end.