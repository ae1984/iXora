/* questions.f
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
        31/12/99 suchkov
 * CHANGES

     27-07-2004      torbaev                добавлена переменная gcount во фрейме fr3 
                                            (отражает общее количество запросов клиентов).

*/

/* ----------------------- Для ввода новой темы ----------------------- */ 

define frame fr-1
       them.them format "x(110)" label "Тема"
       with width 120 side-label centered row 5 title "Введите новую тему" .

/* ----------------------- Для ввода новой подтемы ------------------- */ 
           
define frame fr-2
       sthem.sub format "x(110)" no-label
       with width 120 side-label centered row 5 title "Введите новую подтему" .
             
/* --------------------- Для ввода нового вопроса ------------------ */ 

define frame fr-3
       ques.ques VIEW-AS EDITOR SIZE 30 BY 18 SCROLLBAR-VERTICAL
       ques.answ VIEW-AS EDITOR SIZE 70 BY 18 SCROLLBAR-VERTICAL
       with overlay width 120 side-labels column 2 row 22 .

/* --------------------- Для ввода новой темы --------------------- */ 

define frame fr-4
       samp format "x(50)"
       with width 120 side-label centered row 5 title "Введите образец поиска" .

/* --------------------- Для ввода диапазона --------------------- */ 

define frame fr-5
       per-s label "C"
       per-po label "ПО"
       with width 120 side-label centered row 5 title "Введите диапазон" .

/* --------------------- Для вывода валют --------------------- */ 

define frame fr-6
       crc.crc crc.des crc.code crc.rate[1]
       with overlay width 120 centered title "Курсы валют на сегодня" .

/* ---------------- Для ввода нового вопроса без ответа ---------------- */ 

define frame fr-7
       nques.ques VIEW-AS EDITOR SIZE 100 BY 18 SCROLLBAR-VERTICAL
       with overlay width 120 side-labels column 2 row 22 title "Введите новый вопрос".

/* --------------------- Для ввода опросных данных ------------------ */ 

define frame fr-8
       opros.ques format "x(110)" no-label
       with width 120 side-labels row 2 .

/* --------------------- Для вывода опросных данных ------------------ */ 

/*define frame fr-9
       opr.ques format "x(90)" opr.nu 
       with width 120 side-labels row 2 .*/
  
/* ---------------------- Для ввода темы ------------------------- */ 

define query q1 for them.
define browse b1 query q1 
              displ
                 them.them format "x(110)" label "Тема"
                 with 30 down .
define frame fr1 b1 with width 120 side-labels column 2 .

/* --------------------- Для ввода новой подтемы ----------------- */ 

define query q2 for them.       /*Сначала выбрать тему*/
define browse b2 query q2 
              display
                 them.them format "x(110)" label "Тема"
                 with 30 down .
define frame fr2 b2 with overlay width 120 side-labels column 2 .

/*===============================================================*/
/* --------------------- Для вывода статистики ----------------- */ 

define query q3 for sttab.       /*Сначала выбрать тему*/
define browse b3 query q3 
              display
                 sttab.ques format "x(60)"
                 sttab.dat label "Дата последнего изменения " 
		 sttab.frq label "Количество запросов "
                 with 15 down .
define frame fr3 b3
 skip(0) space(75) gcount view-as text 
with overlay width 120 side-labels column 2 title "Статистика".

/* -------------------------- Для ввода вопроса ------------------ */ 

define query q4 for them.      /*Сначала выбрать тему*/
define browse b4 query q4 
              displ
                 them.them format "x(110)" label "Тема"
                 with 30 down .
define frame fr4 b4 with width 120 side-labels column 2 .

define query q5 for sthem.     /*Потом выбрать подтему*/
define browse b5 query q5 
              displ
                 sthem.sub format "x(110)" label "Подтема"
                 with 30 down .
define frame fr5 b5 with overlay width 120 side-labels column 2 .


/* -------------------- Для вывода вопроса ------------------------ */ 

define query q6 for them.      /*Сначала выбрать тему*/
define browse b6 query q6 
              displ
                 them.them format "x(110)" label "Тема"
                 with 14 down .
define frame fr6 b6 with overlay side-labels width 120 row 2 column 2 .

define query q7 for sthem.     /*Потом выбрать подтему*/
define browse b7 query q7 
              displ
                 sthem.sub format "x(110)" label "Подтема"
                 with 14 down .
define frame fr7 b7 with overlay side-labels width 120 row 2 column 2 .

/* -------------- Для вывода вопроса в результате поиска ----------- */ 

define query q8 for ques.
define browse b8 query q8 
              displ
                 ques.ques format "x(110)" label "Вопрос"
                 with 14 down.
define frame fr8 b8 with overlay side-labels width 120 row 2 column 2 .

/* -------------- Для опроса ----------- */ 

define query q9 for opros.
define browse b9 query q9 
              displ
                 opros.ques format "x(110)" label "Вариант"
                 with 14 down .
define frame fr9 b9 with overlay side-labels width 120 row 5 column 2 .

/* -------------- Для опроса ----------- */ 

define query q10 for opr.
define browse b10 query q10 
              displ
                 opr.ques format "x(90)" label "Вопрос"
                 opr.nu                  label "Кол-во ответов"
                 with 30 down .
define frame fr10 b10 with overlay side-labels width 120 row 5 column 2 .


