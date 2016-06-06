/* adres.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Редактирование адреса в формате, необходимом для КФМ
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
        25/02/2010 galina
 * BASES
        BANK
 * CHANGES
        07/03/2010 madiyar - добавил код страны
        12/03/2010 galina - заменила двойную кавычку на одинарную
        05/03/2011 madiyar - замена запятых на пробелы в элементах адреса
*/


on 'END-ERROR' of frame fadr do:
  hide frame fadr no-pause.
  {&hide}
end.

assign v-country2 = ''
       v-country_cod = ''
       v-region = ''
       v-city = ''
       v-street = ''
       v-house = ''
       v-office = ''
       v-index = ''.

if num-entries(v-adres) = 7 then do:
    v-country2 = entry(1,v-adres).
    if num-entries(v-country2,'(') = 2 then v-country_cod = substr(entry(2,entry(1,v-adres),'('),1,2).
    assign v-country2 = trim(entry(1,entry(1,v-adres),'('))
          v-region = entry(2,v-adres)
          v-city = entry(3,v-adres)
          v-street = entry(4,v-adres)
          v-house = entry(5,v-adres)
          v-office = entry(6,v-adres)
          v-index = entry(7,v-adres).
end.
else assign v-country2 = ''
            v-country_cod = ''
            v-region = ''
            v-city = ''
            v-street = ''
            v-house = ''
            v-office = ''
            v-index = ''.

display v-adres with frame fadr.
update v-country2 v-country_cod v-region v-city v-street v-house v-office v-index with frame fadr.
if trim(v-country2) + trim(v-country_cod) + trim(v-region) + trim(v-city) + trim(v-street)+ trim(v-house) + trim(v-office) + trim(v-index) <> '' then
 v-adres = replace(v-country2,',',' ') + ' (' + replace(v-country_cod,',',' ') + '),' +
           replace(v-region,',',' ') + ',' +
           replace(v-city,',',' ') + ',' +
           replace(v-street,',',' ') + ',' +
           replace(v-house,',',' ') + ',' +
           replace(v-office,',',' ') + ',' +
           replace(v-index,',',' ').


hide frame fadr no-pause.





