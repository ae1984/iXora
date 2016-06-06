/* monyear.i
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

/* monyear.i */
for each {1}:
  /*
  repeat inc = 1 to 5:
    find first gl where gl.subled eq "{1}" and gl.level eq inc no-error.
    if not available gl
    then do:
	   output to value(dbname + ".err") append.
	   export "{1}" inc "gl cannot be found...".
	   output close.
	   next.
	 end.

    if gl.type eq "A" or gl.type eq "L" or gl.type eq "O"
    then do:
	   if {1}.dam[inc] - {1}.cam[inc] ge 0
	   then do:
		  {1}.dam[inc] = {1}.dam[inc] - {1}.cam[inc].
		  {1}.cam[inc] = 0.
		end.
	   else do:
		  {1}.cam[inc] = {1}.cam[inc] - {1}.dam[inc].
		  {1}.dam[inc] = 0.
		end.
	 end.
    else if gl.type eq "R" or gl.type eq "E"
    then do:
	   {1}.dam[inc] = 0.     {1}.cam[inc] = 0.
	 end.
  end.
    */
    {1}.mdam[1] = {1}.dam[1].   {1}.mcam[1] = {1}.cam[1].
    {1}.mdam[2] = {1}.dam[2].   {1}.mcam[2] = {1}.cam[2].
    {1}.mdam[3] = {1}.dam[3].   {1}.mcam[3] = {1}.cam[3].
    {1}.mdam[4] = {1}.dam[4].   {1}.mcam[4] = {1}.cam[4].
    {1}.mdam[5] = {1}.dam[5].   {1}.mcam[5] = {1}.cam[5].
    {1}.ydam[1] = {1}.dam[1].   {1}.ycam[1] = {1}.cam[1].
    {1}.ydam[2] = {1}.dam[2].   {1}.ycam[2] = {1}.cam[2].
    {1}.ydam[3] = {1}.dam[3].   {1}.ycam[3] = {1}.cam[3].
    {1}.ydam[4] = {1}.dam[4].   {1}.ycam[4] = {1}.cam[4].
    {1}.ydam[5] = {1}.dam[5].   {1}.ycam[5] = {1}.cam[5].
end.
