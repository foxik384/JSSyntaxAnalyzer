%token 

/* ----- JS reserved words ----- */
BREAK CASE CATCH CLASS CONST CONTINUE DEBUGGER DEFAULT
DELETE DO ELSE ENUM EXPORT EXTENDS FALSE FINAL FINALLY FOR FUNCTION
IF IMPLEMENTS IMPORT IN INSTANCEOF NEW NUL
RETURN SUPER SWITCH
THIS THROW TRUE TRY TYPEOF VAR VOID WHILE WITH
UNDEFINED NAN INFINITY COMPONENTS_UTILS_IMPORT
GET SET

/*
Deprecated:
LONG SHORT INT FLOAT DOUBLE CHAR BYTE GOTO NATIVE PACKAGE PRIVATE PROTECTED
PUBLIC STATIC SYNCHRONIZED THROWS TRANSIENT VOLATILE ABSTRACT
BOOLEAN INTERFACE
*/
/* ----- JS reserved words ----- */

DOT 	// access operator '.'
COMA	// enum operator ','
COLON	// refinement operator ':'
QMARK	// question mark '?'

// () [] {} brackets
LBRACKET_ROUND		// '('
RBRACKET_ROUND		// ')'
LBRACKET_SQUARE		// '['
RBRACKET_SQUARE		// ']'
LBRACKET_CURLY		// '{'
RBRACKET_CURLY		// '}'

// literals
INT_NUM
LITERAL_NUMBER
OBJ_NAME

// constant string
CSTRING

END_OP

ENDLINE

// assignment operator
OP_ASSIGN			//	=
OP_ASSIGN_ADD   	// +=
OP_ASSIGN_SUB   	// -=
OP_ASSIGN_MUL   	// *=
OP_ASSIGN_POW   	// **=
OP_ASSIGN_DIV   	// /=
OP_ASSIGN_MOD   	// %=
OP_ASSIGN_LSHIFT	// <<=, <<<=
OP_ASSIGN_RSHIFT	// >>=, >>>=
OP_ASSIGN_AND		// &=
OP_ASSIGN_XOR		// ^=
OP_ASSIGN_OR 		// |=


// logical operation tokens
OPL_NOT		// !
OPL_AND		// &&
OPL_OR		// ||
OPL_EQ		// == equal
OPL_NEQ		// != not equal
OPL_L		// < less
OPL_G		// > greater
OPL_GE		// >= greater equal
OPL_LE		// <= less equal


// bitwise operation tokens
OPB_NOT		// ~
OPB_OR		// |
OPB_AND		// &
OPB_XOR		// ^
OPB_LSHIFT	// <<, <<<
OPB_RSHIFT	// >>, >>>

// arithmetic operation tokens
OPA_MUL // '*'
OPA_DIV // '/'
OPA_MOD // '%'
OPA_ADD // '+'
OPA_SUB // '-'
OPA_INC	// '++'
OPA_DEC // '--'

/////////////////--------------- inline C code

%{	
	#include <malloc.h>
	#include "KurCommon.h"
	
	#ifdef _DEBUG
	#define dbgCoBlck(str) SetTextColor(LIGHT_BLUE);\
								 std::cout << str << std::endl;\
						   RevertColors();

	#define dbgCoExpr(str) SetTextColor(LIGHT_YELLOW);\
								 std::cout << str << std::endl;\
						   RevertColors();

	#define dbgCoOper(str) SetTextColor(LIGHT_GREEN);\
								 std::cout << str << std::endl;\
						   RevertColors();

	#define dbg(str) std::cout << str << std::endl;
	#else
	#define dbgCoBlck(str)
	#define dbgCoExpr(str)
	#define dbgCoOper(str)
	#define dbg(str)
	#endif
%}


/////////////////--------------- inline C code

%start block

// low priority downto max priority
%left COMA
%right OP_ASSIGN OP_ASSIGN_ADD OP_ASSIGN_SUB OP_ASSIGN_MUL OP_ASSIGN_DIV OP_ASSIGN_MOD OP_ASSIGN_LSHIFT OP_ASSIGN_RSHIFT OP_ASSIGN_AND OP_ASSIGN_XOR OP_ASSIGN_OR OP_ASSIGN_POW
%left QMARK COLON
%left OPL_OR
%left OPL_AND
%left OPB_OR 
%left OPB_XOR
%left OPB_AND 
%left OPL_EQ OPL_NEQ
%left IN INSTANCEOF OPL_L OPL_G	OPL_GE OPL_LE
%left OPB_LSHIFT OPB_RSHIFT	
%left OPA_ADD OPA_SUB
%left OPA_MUL OPA_DIV OPA_MOD 
%right OPA_POW
%right OPL_NOT OPB_NOT TYPEOF VOID DELETE OPA_INC OPA_DEC /* and unary +, - */
%left NEW LBRACKET_SQUARE RBRACKET_SQUARE DOT
%left END_OP
%nonassoc NO_ELSE
%nonassoc ELSE
%nonassoc LBRACKET_ROUND RBRACKET_ROUND

%%

block:
			blck_function_expression 							{dbgCoBlck("block: blck_function_expression")}
			| block blck_function_expression 					{dbgCoBlck("block: ... blck_function_expression")}			

			| LBRACKET_CURLY block RBRACKET_CURLY				{dbgCoBlck("block: { block }")}
			| block LBRACKET_CURLY block RBRACKET_CURLY			{dbgCoBlck("block: ... { block }")}

			| LBRACKET_CURLY RBRACKET_CURLY						{dbgCoBlck("block: { }")}
			| block LBRACKET_CURLY RBRACKET_CURLY				{dbgCoBlck("block: { }")}

			| universal_single_block 							{dbgCoBlck("block: universal_single_block")}
			| block universal_single_block 						{dbgCoBlck("block: ... universal_single_block")}

			| label_expression
			| block label_expression

single_block:
			function_expression 								{dbg("single_block: function_expression")}

			| LBRACKET_CURLY block RBRACKET_CURLY				{dbg("single_block: { block }")}
			| LBRACKET_CURLY RBRACKET_CURLY						{dbg("single_block: { }")}

			| universal_single_block 							{dbg("single_block: universal_single_block")}

universal_single_block:
			expression END_OP									{dbg("universal_single_block: a + 0;")}
			| reserved_expressions 								{dbg("universal_single_block: reserved_expressions")}
			| var_init END_OP									{dbg("universal_single_block: variable initialization;")}
			
			| operators 										{dbg("universal_single_block: operators")}

/* ++@++ Label statement ++@++ */
val_lbl:
			literal_string
			| GET
			| SET

label:
			val_lbl COLON 								{dbg("label: lbl1 :")}
			| val_lbl literal_string COLON						{dbg("label: ... lbl1 :")}

label_expression:
			label   blck_function_expression 			{dbg("label_expression: label : blck_function_expression")}
			| label LBRACKET_CURLY block RBRACKET_CURLY {dbg("label_expression: label : { block }")}
			| label LBRACKET_CURLY RBRACKET_CURLY 		{dbg("label_expression: label : { }")}
			| label universal_single_block 				{dbg("label_expression: label : universal_single_block")}
/* --!-- Switch statement --!-- */

operators:
			if_operator 										{dbgCoOper("operators: if ()")}

			| switch_operator 									{dbgCoOper("operators: switch")}

			| while_operator 									{dbgCoOper("operators: while")}

			| for_operator 										{dbgCoOper("operators: for")}

			| do_operator 										{dbgCoOper("operators: do ... while();")}

			| try_operator 										{dbgCoOper("operators: try");}

			| throw_operator 									{dbgCoOper("operators: throw")}

			| return_operator 									{dbgCoOper("operators: return")}

			| break_operator 									{dbgCoOper("operators: break")}

			| continue_operator 								{dbgCoOper("operators: continue")}

gen_list:
			LBRACKET_SQUARE parameters RBRACKET_SQUARE

/* /// Javascript reserved expressions \\\ */

reserved_expressions:
			components_utils_import_expression

components_utils_import_expression:
			COMPONENTS_UTILS_IMPORT LBRACKET_ROUND parameters RBRACKET_ROUND END_OP

/* \\\ Javascript reserved expressions /// */

continue_operator:
			CONTINUE END_OP 									{dbg("continue_operator: continue ;")}
			| CONTINUE literal_string END_OP 					{dbg("continue_operator: continue a ;")}

break_operator:
			BREAK END_OP 										{dbg("break_operator: break ;")}
			| BREAK literal_string END_OP 						{dbg("break_operator: break a ;")}

/* ++@++ return statement ++@++ */
//I do not undestand what is that. Is the specific return expression?..
//But Ok I Will implement that:
//(line 5265) {
//                rng : rng; scrollX : sx; scrollY : sy};

strange_expression:
			literal_string COLON init_value 												{dbg("strange_expression: a : init_value")}
			| strange_expression END_OP literal_string COLON init_value 					{dbg("strange_expression: ... ; a : init_value")}
			|

return_operator:
			RETURN LBRACKET_CURLY strange_expression RBRACKET_CURLY END_OP 					{dbg("return_operator: return { strange_expression } ;")}
			| RETURN function_expression 													{dbg("single_block: function_expression")}
			| RETURN universal_single_block 												{dbg("single_block: universal_single_block")}
			//| gen_list
/* --!-- return statement --!-- */

throw_operator:
			THROW single_block 																{dbg("throw_operator: throw single_block")}

try_operator:
			TRY LBRACKET_CURLY block RBRACKET_CURLY catch_operator 										{dbg("try_operator: try { block } catch_operator")}
			| TRY LBRACKET_CURLY RBRACKET_CURLY catch_operator 											{dbg("try_operator: try { } catch_operator")}
			| TRY LBRACKET_CURLY block RBRACKET_CURLY finally_operator									{dbg("try_operator: try { block } finally ...")}

finally_operator:
			FINALLY LBRACKET_CURLY block RBRACKET_CURLY 												{dbg("finally_operator: finally { block }")}
			| FINALLY LBRACKET_CURLY RBRACKET_CURLY														{dbg("finally_operator: finally { }")}

catch_operator:
			CATCH LBRACKET_ROUND literal_string RBRACKET_ROUND LBRACKET_CURLY block RBRACKET_CURLY 		{dbg("catch_operator: catch (a) { block }")}
			| CATCH LBRACKET_ROUND literal_string RBRACKET_ROUND LBRACKET_CURLY RBRACKET_CURLY 			{dbg("catch_operator: catch (a) { }")}
			| CATCH LBRACKET_CURLY block RBRACKET_CURLY													{dbg("catch_operator: catch { block }")}
			| CATCH LBRACKET_CURLY RBRACKET_CURLY														{dbg("catch_operator: catch { }")}
			| catch_operator FINALLY LBRACKET_CURLY block RBRACKET_CURLY 								{dbg("catch_operator: ... finally { block }")}

do_operator:
			DO single_block WHILE LBRACKET_ROUND expression RBRACKET_ROUND END_OP 	{dbg("do_operator: do ... while(expression);")}

while_operator:
			WHILE LBRACKET_ROUND expression RBRACKET_ROUND single_block 	{dbg("while_operator: while (expression) block")}

for_operator:

			FOR LBRACKET_ROUND expression END_OP expression END_OP expression RBRACKET_ROUND single_block 	{dbg("for_operator: for(i=0; i < 4; i++) block")}
			| FOR LBRACKET_ROUND var_init END_OP expression END_OP expression RBRACKET_ROUND single_block 	{dbg("for_operator: for(var i=0; i < 4; i++) block")}
			| FOR LBRACKET_ROUND expression RBRACKET_ROUND single_block
			| FOR LBRACKET_ROUND VAR expression RBRACKET_ROUND single_block
			//| FOR LBRACKET_ROUND var_init IN object RBRACKET_ROUND single_block 							{dbg("for(var i in obj) block")}
			//| FOR LBRACKET_ROUND literal_string IN object RBRACKET_ROUND single_block 						{dbg("for(i in obj) block")}

/* ++@++ Switch statement ++@++ */

switch_operator:
			SWITCH LBRACKET_ROUND expression RBRACKET_ROUND LBRACKET_CURLY case_expression default_operator RBRACKET_CURLY 		{dbg("switch_operator: (expression) { case_expression default_operator }")}
			| SWITCH LBRACKET_ROUND expression RBRACKET_ROUND LBRACKET_CURLY default_operator RBRACKET_CURLY 					{dbg("switch_operator: (expression) { default_operator }")}

default_operator:
			DEFAULT COLON block 								{dbg("default_operator: default: block")}
			| 													{dbg("default_operator: <nothing>")}

case_expression:
			CASE expression COLON block 						{dbg("case_expression: case 1: block")}
			| case_expression CASE expression COLON block 		{dbg("case_expression: ... case 1: block")}
			| CASE expression COLON 							{dbg("case_expression: case 1:")}
			| case_expression CASE expression COLON 			{dbg("case_expression: ... case 1:")}
//			|
/* --!-- Switch statement --!-- */

/* ++@++ If statement ++@++ */

if_operator:
			IF LBRACKET_ROUND expression RBRACKET_ROUND single_block %prec NO_ELSE	 	 {dbg("if_operator: if (expression) block")}
			| IF LBRACKET_ROUND expression RBRACKET_ROUND single_block ELSE single_block {dbg("if_operator: if (expression) single_stat_blck else single_stat_blck")}

/* --!-- If statement --!-- */


/* ++@++ Variable initialization ++@++ */

var_init:
			VAR var 											{dbg("var_init: var a...; (local variable)")}
			| assign_expression COMA var						{dbg("var_init: a...; (global variable)")}

var:
			literal_string
			| var COMA literal_string							{dbg("var: ...a")}
			| assign_expression 								{dbg("var: a = 0;")}
			| var COMA assign_expression 						{dbg("var: a = 0, ...")}

init_block:
			literal_string COLON init_value 												{dbg("init_block: a : init_value")}
			| constant_string COLON init_value 												{dbg("init_block: 'vara' : init_value")}
			| LBRACKET_SQUARE expression RBRACKET_SQUARE COLON init_value					{dbg("init_block: ['vara' + a] : init_value")}
			| DOT DOT DOT object 															{dbg("init_block: ... obj(clone object)")}
			| CLASS COLON init_value
			| GET object LBRACKET_CURLY block RBRACKET_CURLY
			| SET object LBRACKET_CURLY block RBRACKET_CURLY
			| GET COLON init_value
			| SET COLON init_value
			| VAR assign_expression

			| init_block COMA literal_string COLON init_value 								{dbg("init_block: ... , a : init_value")}
			| init_block COMA constant_string COLON init_value 								{dbg("init_block: ... , 'vara' : init_value")}
			| init_block COMA LBRACKET_SQUARE expression RBRACKET_SQUARE COLON init_value 	{dbg("init_block: ... , ['vara' + a] : init_value")}
			| init_block COMA DOT DOT DOT object 											{dbg("init_block: ... , ...obj(clone object)")}
			| init_block COMA CLASS COLON init_value
			| init_block COMA GET object LBRACKET_CURLY block RBRACKET_CURLY
			| init_block COMA SET object LBRACKET_CURLY block RBRACKET_CURLY
			| init_block COMA GET COLON init_value
			| init_block COMA SET COLON init_value
			| init_block COMA VAR assign_expression
			|

//strange_square_parameters:
//			LBRACKET_SQUARE RBRACKET_SQUARE
//			//| object
//			| strange_square_parameters COMA LBRACKET_SQUARE RBRACKET_SQUARE
//			//| strange_square_parameters COMA object

init_value:
			expression 											{dbg("init_value: expression")}
			| function_expression								{dbg("init_value: function_expression")}
			| LBRACKET_CURLY init_block RBRACKET_CURLY 			{dbg("init_value: { init_block }")}
			//| gen_list
			//| LBRACKET_SQUARE strange_square_parameters RBRACKET_SQUARE 	{dbg("init_value: [[], []]")}

/* --!-- Variable initialization --!-- */

/* ++@++ Function expression ++@++ */

blck_function_expression:
			FUNCTION literal_string LBRACKET_ROUND func_parameters RBRACKET_ROUND LBRACKET_CURLY func_body RBRACKET_CURLY 	{dbg("function: function literal_string (parameters) { func_body }")}
			| iif_expression END_OP
			//| LBRACKET_ROUND FUNCTION func_name LBRACKET_ROUND func_parameters RBRACKET_ROUND LBRACKET_CURLY func_body RBRACKET_CURLY RBRACKET_ROUND LBRACKET_ROUND RBRACKET_ROUND END_OP

/* What an idiots decide to implement that:
(function() {})();
*/

iif_expression:
			LBRACKET_ROUND FUNCTION func_name LBRACKET_ROUND func_parameters RBRACKET_ROUND LBRACKET_CURLY func_body RBRACKET_CURLY LBRACKET_ROUND RBRACKET_ROUND RBRACKET_ROUND

function_expression:
			FUNCTION func_name LBRACKET_ROUND func_parameters RBRACKET_ROUND LBRACKET_CURLY func_body RBRACKET_CURLY	{dbg("function: function func_name (parameters) { func_body }")}
			| iif_expression	{dbg("function: (function func_name (parameters) { func_body }())")}

func_body:
			block 												{dbg("func_body: block")}
			|													{dbg("func_body: <nothing>")}

func_name:
			literal_string 										{dbg("func_name: name")}
			| 													{dbg("func_name: <nothing>")}

func_parameters:
			literal_string 										{dbg("func_parameters: a")}		
			| func_parameters COMA literal_string 				{dbg("func_parameters: ... , a")}				
			| 													{dbg("func_parameters: <nothing>")}		

/* --!-- Function expression --!-- */

/* ++@++ Expressions ++@++ */

expression: 
			// expr in brackets
			//| LBRACKET_ROUND expression RBRACKET_ROUND DOT refinements_and_calls 	{dbg("(expr).f(). ...")	}
			
			////------ expression operands end

			//round_bracket_expression

			assign_expression									{dbgCoExpr("expression: assign_expression")}
			| shortened_expression 								{dbgCoExpr("expression: shortened_expression")}
			| binary_expression 								{dbgCoExpr("expression: binary_expression")}
			| ternary_expression 								{dbgCoExpr("expression: ternary_expression")}
			| unary_expression									{dbgCoExpr("expression: unary_expression")}
			| new_expression 									{dbgCoExpr("expression: new_expression")}
			| delete_expression 								{dbgCoExpr("expression: delete_expression")}

			| object 											{dbgCoExpr("expression: object")}

			| literal_number 									{dbgCoExpr("expression: literal_number")}
			//| constant_string 									{dbgCoExpr("expression: constant_string")}

			| empty_expression 									{dbgCoExpr("expression: empty_expression")}

			| useful_words										{dbgCoExpr("expression: useful_words")}

			| typeof_operator 									{dbgCoExpr("expression: typeof_operator")}

			| THIS 												{dbgCoExpr("expression: this")}

			| object INSTANCEOF object 		 					{dbgCoExpr("expression: object instanceof constructor")}

			| in_expression 									{dbgCoExpr("expression: property in object")}

			| round_bracket_expression
			| round_bracket_expression DOT object

			| square_bracket_expression

square_bracket_enum:
			expression
			| square_bracket_enum COMA expression

square_bracket_expression:
			LBRACKET_SQUARE square_bracket_enum RBRACKET_SQUARE

round_bracket_expression:
			LBRACKET_ROUND expression RBRACKET_ROUND			{dbgCoExpr("expression: (a+0)")}
			| LBRACKET_ROUND function_expression RBRACKET_ROUND			{dbgCoExpr("expression: (a+0)")}

in_expression:
			expression IN expression							{dbg("in_expression: 'propA' in object")}
			//| expression IN gen_list							{dbg("in_expression: 'propA' in object")}

typeof_operator:
			TYPEOF expression 									{dbg("typeof_operator: typeof expression")}

shortened_expression:
			object OP_ASSIGN_ADD 		expression 				{dbg("shortened_expression: a += a")}
			| object OP_ASSIGN_SUB		expression 				{dbg("shortened_expression: a -= a")}
			| object OP_ASSIGN_MUL		expression 				{dbg("shortened_expression: a *= a")}
			| object OP_ASSIGN_POW		expression 				{dbg("shortened_expression: a **= a")}
			| object OP_ASSIGN_DIV		expression 				{dbg("shortened_expression: a /= a")}
			| object OP_ASSIGN_MOD		expression 				{dbg("shortened_expression: a %= a")}
			| object OP_ASSIGN_LSHIFT	expression 				{dbg("shortened_expression: a >>= a, a >>>= a")}
			| object OP_ASSIGN_RSHIFT	expression 				{dbg("shortened_expression: a <<= a, a <<<= a")}
			| object OP_ASSIGN_AND		expression 				{dbg("shortened_expression: a &= a")}
			| object OP_ASSIGN_XOR		expression 				{dbg("shortened_expression: a ^= a")}
			| object OP_ASSIGN_OR		expression 				{dbg("shortened_expression: a |= a")}

//expression_enum:
//			expression 											{dbg("expression_enum: expression")}
//			| expression_enum COMA expression 					{dbg("expression_enum: ... , expression")}
//			
//			| function_expression 								{dbg("expression_enum: function_expression")}
//			| expression_enum COMA function_expression 			{dbg("expression_enum: ... , function_expression")}

			//| LBRACKET_SQUARE RBRACKET_SQUARE
			//| expression_enum COMA LBRACKET_SQUARE RBRACKET_SQUARE

assign_expression:
			object OP_ASSIGN expression 						{dbg("assign_expression: this.a = 0")}
			| object OP_ASSIGN function_expression 				{dbg("assign_expression: this.a = function_expression")}
			| object OP_ASSIGN LBRACKET_CURLY init_block RBRACKET_CURLY		{dbg("assign_expression: a = { init_block }")}
//			| object OP_ASSIGN LBRACKET_SQUARE expression_enum RBRACKET_SQUARE 	{dbg("assign_expression: a = [ expression ]")}

new_expression:
			NEW expression 										{dbg("new_expression: new a()")}

delete_expression:
			DELETE object;

empty_expression:
			{dbg("empty_expression: ;")}

useful_words:
			NUL 												{dbg("useful_words: null")}
			| TRUE 												{dbg("useful_words: true")}
			| FALSE 											{dbg("useful_words: false")}
			| UNDEFINED 										{dbg("useful_words: undefined")}
			| NAN 												{dbg("useful_words: NaN")}
			| INFINITY 											{dbg("useful_words: Infinity")}

unary_expression:
			/* prefix expression */
			OPA_INC object				{dbg("unary_expression: ++ a")}
			| OPA_INC LBRACKET_ROUND object RBRACKET_ROUND 		{dbg("unary_expression: ++ (a)")}
			| OPA_DEC object	 		{dbg("unary_expression: -- a")}
			| OPA_DEC LBRACKET_ROUND object RBRACKET_ROUND 		{dbg("unary_expression: -- (a)")}

			/* postfix expression */
			/* надо подумать на счёт этого. Возможно придётся реализовать 
			   второй тип expression - bracket expression */
			| object OPA_INC 			{dbg("unary_expression: a ++")}
			//| LBRACKET_ROUND object RBRACKET_ROUND OPA_INC 		{dbg("unary_expression: (a) ++")}
			| object OPA_DEC 			{dbg("unary_expression: a --")}
			//| LBRACKET_ROUND literal_string RBRACKET_ROUND OPA_DEC 	{dbg("unary_expression: (a) --")}
			| OPL_NOT expression 				{dbg("unary_expression: !a")}

binary_expression:
			expression OPA_MUL 		expression 	{dbg("binary_expression: a * a")}
			| expression OPA_DIV    expression	{dbg("binary_expression: a / a")}	
			| expression OPA_MOD    expression	{dbg("binary_expression: a % a")}
			| expression OPA_SUB 	expression 	{dbg("binary_expression: a - a")}
			| expression OPA_ADD	expression 	{dbg("binary_expression: a + a")}
			                                          
			| expression OPL_AND	expression 	{dbg("binary_expression: a && a")}	
			| expression OPL_OR 	expression 	{dbg("binary_expression: a || a")}
			| expression OPL_EQ 	expression 	{dbg("binary_expression: a == a, a === a")}
			| expression OPL_NEQ	expression 	{dbg("binary_expression: a != a, a !== a")} 
			| expression OPL_L  	expression 	{dbg("binary_expression: a < a")}
			| expression OPL_G  	expression 	{dbg("binary_expression: a > a")}
			| expression OPL_GE 	expression 	{dbg("binary_expression: a <= a")}
			| expression OPL_LE 	expression 	{dbg("binary_expression: a >= a")}
			                                          
			| expression OPB_AND    expression	{dbg("binary_expression: a & a")}
			| expression OPB_OR     expression	{dbg("binary_expression: a | a")}
			| expression OPB_XOR    expression	{dbg("binary_expression: a ^ a")}
			| expression OPB_LSHIFT expression	{dbg("binary_expression: a << a, a <<< a")} 
			| expression OPB_RSHIFT expression	{dbg("binary_expression: a >> a, a >>> a")}

ternary_expression:
			expression QMARK expression COLON expression {dbg("ternary_expression: (a > 0) ? 1 : 0")}

/* ++@++ Objects ++@++ */

parameters:
			expression 											{dbg("parameters: 1")}
			| function_expression 								{dbg("parameters: function_expression")}
			| LBRACKET_CURLY init_block RBRACKET_CURLY 			{dbg("parameters: { init_block }")}
			
			| parameters COMA expression 						{dbg("parameters: ... , 1")}
			| parameters COMA function_expression 				{dbg("parameters: ... , function_expression")}
			| parameters COMA LBRACKET_CURLY init_block RBRACKET_CURLY 	{dbg("parameters: ... , { init_block }")}

object:
			object LBRACKET_ROUND parameters RBRACKET_ROUND 	{dbg("object: ... ( parameters )")}
			//| LBRACKET_ROUND parameters RBRACKET_ROUND
			| object gen_list 								    {dbg("object: ... [ parameters ]")}
			| object DOT GET
			| object DOT SET
			| GET
			| SET
			| literal_string	 								{dbg("object: a")}
			| object DOT literal_string							{dbg("object: ... .a")}
			| THIS DOT literal_string 							{dbg("object: this.a")}
			| THIS LBRACKET_SQUARE parameters RBRACKET_SQUARE
			| constant_string
			//| round_bracket_expression

/* --!-- Objects --!-- */

/* --!-- Expressions --!-- */

			
/////////////////--------------- literals

literal_string : OBJ_NAME 						{dbg("Literal string")	}
constant_string: CSTRING 						{dbg("Constant string");}
literal_number: LITERAL_NUMBER 					{dbg("Literal number")	}

/////////////////--------------- literals

%%

void yyYaccInit() {}
void yyYaccCleanup() {}