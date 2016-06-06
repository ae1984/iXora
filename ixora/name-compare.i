/* name-compare.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* --------------------------------------------- 
 * NAME-COMPARE.i  - Функции для сравнивания 
 * наименований клиентов с заданной строкой      

 * Для использования функций обязательно 

 * GCompare - основная функция
      сравнивает строки (образец, проверяемая строка, ключ)
      ключ - это обычно CIF клиента; по нему в справочнике 
      ищутся допустимые наименования образца

 * GFullCompare - вспомогательная функция
      получает (1)образец, 
               (2)видоизменяемую для сверки строку,
               (3)подслово для замены в (2)
               (4)список подсов для последующих рекурсивных замен

ПРИМЕРЫ:

1)   GCompare (name1, name2, "")
                 - сравнение name1 с name2 (c использованием
                   только справочника общих сокращений)

2)   GCompare (name1, name2, "T12345")
                 - сравнение name1 с name2 (c использованием
                   справочника общих сокращений, и справочника
                   допустимых названий по ключу "T12345" т.е.
                   в данном случае ключ - это CIF клиента

3)   GFullCompare (name1, name2,        "",  "abc,ABC;def,DEF;ghi,TEST;qwerty,QWERRTY")

4)   ------------------------------------------
     О Ч Е Н Ь    Х О Р О Ш И Й    П Р И М Е Р  
     И   О Ч Е Н Ь    П О Д Р О Б Н Ы Й   ! ! !
     ------------------------------------------
     Сравниваем строку s1 с "56ab1cd2ef3" и знаем, что 
         - вместо 1 иногда может быть 2
         - вместо 3 иногда может быть 4
         - вместо 5 иногда может быть 6
         - иногда может быть и все вместе или вперемешку
           (ну может же в строке быть ошибка!)
  
     список сокращений: "сокращенное , полное ; сокращенное , полное ; ..."
     Строка вызова сравнения:   GFullCompare (s1, "56ab1cd2ef3", "", "1,2;3,4;5,6")

     Дерево получаемых рекурсией вызовов:
     -----------------------------------
   > GFullCompare (s1, "56ab1cd2ef3", "", "1,2;3,4;5,6")

     GFullCompare (s1, "56ab1cd2ef3", "1,2", "3,4;5,6")

	GFullCompare (s1, "56ab2cd2ef3", "3,4", "5,6")
        
        	GFullCompare (s1, "56ab2cd2ef4", "5,6", "")
        	
        		GFullCompare (s1, "66ab2cd2ef4", "", "")

     	GFullCompare (s1, "56ab2cd2ef3", "5,6", "3,4")
     	
     		GFullCompare (s1, "66ab2cd2ef3", "3,4", "")
        	
        		GFullCompare (s1, "66ab2cd2ef4", "", "")

     GFullCompare (s1, "56ab1cd2ef3", "3,4", "1,2;5,6")
     
	GFullCompare (s1, "56ab1cd2ef4", "1,2", "5,6")
     	
     		GFullCompare (s1, "56ab2cd2ef4", "5,6", "")
     		
     			GFullCompare (s1, "66ab2cd2ef4", "", "")

     	GFullCompare (s1, "56ab1cd2ef4", "5,6", "1,2")
     	
     		GFullCompare (s1, "66ab1cd2ef4", "1,2", "")
     		
     			GFullCompare (s1, "66ab2cd2ef4", "", "")

     GFullCompare (s1, "56ab1cd2ef3", "5,6", "1,2;3,4")
     
	GFullCompare (s1, "66ab1cd2ef3", "1,2", "3,4")
     	
     		GFullCompare (s1, "66ab2cd2ef3", "3,4", "")
     		
     			GFullCompare (s1, "66ab2cd2ef4", "", "")

     	GFullCompare (s1, "66ab1cd2ef3", "3,4", "1,2")
     	
     		GFullCompare (s1, "66ab1cd2ef4", "1,2", "")
     		
     			GFullCompare (s1, "66ab2cd2ef4", "1,2", "")

  > КОНЕЦ РЕКУРСИВНЫХ ВЫЗОВОВ

  > Если во время одного из вызовов второй параметр совпадет с первым,
    или второй параметр совпадет с одной из форм в списке Sokrat_keyz
    (если этот список сформировать заранее...) то результат сравнения 
    будет положительным
  

-----------------------------------------------*/

{trim.i}
{comm-txb.i}

define var G_eng_str1 as char NO-UNDO init "".
define var G_eng_str2 as char NO-UNDO init "".
define var Sokrat_keyz as char NO-UNDO init "".
define var seltxb as int NO-UNDO.

seltxb = comm-cod().


/* Сравнение двух строк: */
/*     S1 - образец      */
/*     S2 - что сравнить */
/*     sw - что на что подставить */
/*     sf - дальнейший список что подставлять */
/*    skey - CIF клиента       */
function GFullCompare returns logical (s1 as char, s2 as char, sw as char, sf as char).
   def var ent1 as char no-undo.
   def var ent2 as char no-undo.
   def var new2 as char no-undo.
   def var i    as int  no-undo.
   def var j    as int  no-undo.

   &SCOPED-DEFINE s-what  ENTRY(i, sf, ";")
   &SCOPED-DEFINE s-full  if j = 1 then "" else REPLACE (sf, (if i = j then ";" else "") + ENTRY(i, sf, ";") + (if i = j then "" else ";" ), "")

   if sw = "" then new2 = s2.
   else do:
       ent1 = ENTRY(1, sw, ",").
       ent2 = ENTRY(2, sw, ",").
       new2 = REPLACE (CAPS(s2), CAPS(ent1), CAPS(ent2)).
   end.

   G_eng_str2 = GPSTrim (GEnglish(new2)).

   if G_eng_str1 = G_eng_str2 then return TRUE.

   /* обработка тех строк, которые пустые (а то будет matches по паре sw/sf) */
   if G_eng_str1 = ""  and G_eng_str2 <> "" then return FALSE.
   if G_eng_str1 <> "" and G_eng_str2 =  "" then return FALSE.

   /* подстановка вариантов полного названия */
   repeat i = 1 to num-entries (Sokrat_keyz, ";"):
         if ENTRY(i, Sokrat_keyz, ";") = G_eng_str2 then return TRUE.
   end.

   /* перебор всех возможных замен подслова */ 
   j = num-entries (sf, ";").
   do i = 1 to j:
      if GFullCompare ( s1, new2, {&s-what}, {&s-full} ) then return TRUE.
   end.

   return FALSE.

end function.


/* Сравнение двух строк: */
/*     S1 - образец      */
/*     S2 - что сравнить */
/*    SKey - ключ для sokrat - CIF клиента */
function GCompare returns logical (s1 as char, s2 as char, skey as char).
    def var strF as char NO-UNDO.

    if GPSTrim (s1) = GPSTrim (s2) then return TRUE.
    G_eng_str1 = GPSTrim (GEnglish (s1)).

    strF = "".
    /* список сокращений: ...; сокращенное, полное; сокращенное, полное; ... */
    /* сокращения БЕЗ ТРАНСЛИТА */
    for each sokrat where sokrat.type = 2 no-lock use-index type-key:
        strF = strF + ";" + 
               trim (sokrat.key) + "," + 
               REPLACE (sokrat.full, ";", "").
    end.
    /* сокращения С ТРАНСЛИТОМ */
    for each sokrat where sokrat.type = 3 no-lock use-index type-key:
        strF = strF + ";" + 
               trim (sokrat.key) + "," + 
               REPLACE (sokrat.full, ";", "").
    end.
    /* сокращения по филиалу */
    for each sokrat where sokrat.txb = seltxb and sokrat.type = 4 no-lock use-index txb-type-key:
        strF = strF + ";" + 
               trim (sokrat.key) + "," + 
               REPLACE (sokrat.full, ";", "").
    end.
    if length (strF) > 0 then strF = SUBSTR (strF, 2).

    Sokrat_keyz = "".
    if skey <> "" then
       for each sokrat where sokrat.txb = seltxb and sokrat.type = 1 and sokrat.key = skey 
                             no-lock use-index txb-type-key:
            Sokrat_keyz = Sokrat_keyz + sokrat.teng + ";".
       end.

    return GFullCompare (s1, s2, "", strF).

end function.

