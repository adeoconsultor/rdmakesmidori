#include 'protheus.ch'
#include 'rwmake.ch'

user function M410PVNF()
	if date() <> ddatabase
		Alert("A Data Base "+dtoc(ddatabase)+" � inv�lida para Gera��o de Nota Fiscal."+chr(13)+chr(10)+;
		'A data correta deve ser '+dtoc(date())+"."+chr(13)+chr(13)+;
		'Se voce continuar poder� ter problema com a transmiss�o da NFE')
	endif

return .t.