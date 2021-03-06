#INCLUDE "TOTVS.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ACDINV02 �Autor  �Antonio Carlos Damaceno � Data �  06/12/16���
�������������������������������������������������������������������������͹��
���Descricao � Rotina de CAD de etq NA TABELA CB0 - PNP2 ���
�������������������������������������������������������������������������͹��
���Uso       �AP11                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
028019|APAPU13416|112401C
*/

User Function ACDINV02()

Local cAlias := "CB0"

Private cCadastro  := OemToAnsi("Cadastro Etq na CB0")
Private aRotina    := { }

AADD(aRotina, { "Pesquisar" , "AxPesqui", 0, 1 })
AADD(aRotina, { "Visualizar", "AxVisual", 0, 2 })
AADD(aRotina, { "Incluir"   , "AxInclui", 0, 3 })
AADD(aRotina, { "Alterar"   , "AxAltera", 0, 4 })
AADD(aRotina, { "Excluir"   , "AxDeleta", 0, 5 })

dbSelectArea(cAlias)
dbSetOrder(1)
mBrowse(6, 1, 22, 75, cAlias)

Return NIL
