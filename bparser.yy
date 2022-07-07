
%{
#include <iostream>
#include <string>
#include <fstream>
#include <map>
#include <list>
#include <iomanip>



std::ifstream input_stream;


enum EXPRESSION{
    NONE,
    INTEGER,
    IDENTIFIER,
    ASSIGN,
    PLUS,
    MINUS,
    MULT,
    DIV,
    MODULO,
    EQUAL,
    LESSER,
    GREATER,
    PARENTHESIS
};

struct Expression{
    enum EXPRESSION type;
    std::list<struct Expression> child_expressions;
    //terminal values
    int integer_value;
    std::string string_value; 
};

enum STATEMENT{
    RETURN,
    RETURNVAL,
    WHILE,
    IF,
    VAR,
    EXPSTAT,
    COMPOUND,
    NOP
};

std::map<enum STATEMENT, std::string> statement_names{
    {RETURN, "return"},{RETURNVAL, "returnval"},{WHILE, "while"},
    {IF, "if"},{VAR, "var"},{EXPSTAT, "exp_statement"}, {COMPOUND, "compound"},
    {NOP, "nop"}
};

std::map<enum EXPRESSION, std::string> expression_names{
    {INTEGER, "integer"},{IDENTIFIER,"identifier"},{ASSIGN, "assign"},
    {PLUS,"plus"},{MINUS, "minus"},{MULT,"mult"},{DIV, "div"},{MODULO, "modulo"},
    {EQUAL, "equal"}, {LESSER, "lesser"}, {GREATER, "greater"},
    {PARENTHESIS, "parenthesis"}
};

struct Statement{
    enum STATEMENT type;
    std::list<Statement> child_statements;
    struct Expression expression;
};

struct Function{
    std::string identifier;
    struct Statement statement;
    std::list<std::string> params;
};

void print_expression(struct Expression e, int indent=4){
    std::cout << std::string(indent, ' ') << expression_names[e.type] << std::endl;
    if(e.type == INTEGER){
        std::cout << std::string(indent+4,' ') << e.integer_value << std::endl;
    }
    if(e.type == IDENTIFIER){
        std::cout << std::string(indent+4,' ') << e.string_value << std::endl;
    }
    for(auto child: e.child_expressions){
        print_expression(child, indent+4);
    }
}

void print_statement(struct Statement s, int indent=4){

    std::cout << std::string(indent, ' ') << statement_names[s.type] << std::endl;

    if(s.expression.type != NONE){
        print_expression(s.expression, indent+4);
    }

    for(auto child: s.child_statements){
        print_statement(child, indent+4);
    }
}

%}

%require "3.2"
%language "c++"
%define api.value.type variant
%define api.token.constructor

%token <std::string> IDENTIFIER
%token <int> INTEGER

%token WHILE IF VAR  RETURN
%token LEFTCURLY RIGHTCURLY

%token PLUS MINUS MULT DIV MODULO EQUAL GREATER LESSER ASSIGN
%token LEFTPAR RIGHTPAR

%token COLON SEMICOLON
%token <std::string> OTHER

%right ASSIGN 
%left EQUAL GREATER LESSER
%left PLUS MINUS
%left MULT DIV MODULO
%left LEFTPAR RIGHTPAR

%code{
namespace yy{

parser::symbol_type yylex(){
    std::string input;
    input_stream >> input;
    
    if(!input.size()) return parser::make_YYEOF();
    const char * start = input.c_str();
    const char * YYCURSOR = start, * YYMARKER;
    
    int len = input.size();
    auto putback = [&YYCURSOR, &len](){
        while(*YYCURSOR){
            input_stream.unget();
            ++YYCURSOR;
            --len;
        }
    };



    /*!re2c
    re2c:define:YYCTYPE = char;
    re2c:yyfill:enable = 0;

        

    *          {return parser::make_OTHER(input);}
    "while"    {putback(); return parser::make_WHILE();}
    "if"       {putback(); return parser::make_IF();}
    "return"   {putback(); return parser::make_RETURN();}
    "var"      {putback(); return parser::make_VAR();}
    [0-9]+     {putback(); return parser::make_INTEGER(strtoll(input.c_str(),0,10));}
    "+"        {putback(); return parser::make_PLUS();}
    "-"        {putback(); return parser::make_MINUS();}
    "*"        {putback(); return parser::make_MULT();}
    "/"        {putback(); return parser::make_DIV();}
    "%"        {putback(); return parser::make_MODULO();}
    "=="       {putback(); return parser::make_EQUAL();}
    ">"        {putback(); return parser::make_GREATER();}
    "<"        {putback(); return parser::make_LESSER();}
    "="        {putback(); return parser::make_ASSIGN();}
    ";"        {putback(); return parser::make_SEMICOLON();}
    ":"        {putback(); return parser::make_COLON();}
    "{"        {putback(); return parser::make_LEFTCURLY();}
    "}"        {putback(); return parser::make_RIGHTCURLY();}
    "("        {putback(); return parser::make_LEFTPAR();}
    ")"        {putback(); return parser::make_RIGHTPAR();}
    [a-zA-Z_]+  {putback(); return parser::make_IDENTIFIER(input.substr(0,len));}



*/
}

}
}

%%

%nterm <struct Expression> expression;
%nterm <struct Statement> statement;
%nterm <struct Statement> compound_statement;
%nterm <struct Function> function;
%nterm <std::list<struct Function>> library;
%nterm <std::list<std::string>> params;

result:
    library {
        for(auto function: $1){
            std::cout<<function.identifier<<std::endl;
            for(auto param: function.params){
                std::cout<<"    "<<param<<std::endl;
            }
            print_statement(function.statement, 4);
        }
    }
;

library:
    %empty {$$=std::list<Function>();}
|   library function {$$ = $1; $$.push_back($2);}
;

function:
    IDENTIFIER statement {$$ = {$1,$2};}
|   IDENTIFIER LEFTPAR params RIGHTPAR statement {$$ = {$1,$5,$3};}
;

params:
    %empty {$$ = std::list<std::string>();}
|   params COLON IDENTIFIER {$$ = $1; $$.push_back($3);}
;


statement:
    compound_statement RIGHTCURLY {$$ = $1; $$.type = COMPOUND;}
|   expression SEMICOLON {$$ = {EXPSTAT}; $$.expression = $1;}
|   IF LEFTPAR expression RIGHTPAR statement {$$ = {IF};$$.child_statements.push_back($5);$$.expression=$3;}
|   WHILE LEFTPAR expression RIGHTPAR statement {$$ = {WHILE};$$.child_statements.push_back($5);$$.expression=$3;}
|   RETURN SEMICOLON {$$ = {RETURN};}
|   RETURN expression SEMICOLON {$$ = {RETURNVAL};$$.expression=$2;}
|   VAR IDENTIFIER SEMICOLON {$$ = {VAR};$$.expression.type=IDENTIFIER;$$.expression.string_value=$2;}
|   SEMICOLON {$$ = {NOP};}
;

compound_statement:
    LEFTCURLY {}
|   compound_statement statement {$$ = $1; $$.child_statements.push_back($2);}
;

expression:
    INTEGER {$$={INTEGER};$$.integer_value=$1;}
|   expression ASSIGN expression {$$={ASSIGN};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression PLUS expression {$$={PLUS};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression MINUS expression {$$={MINUS};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression MULT expression {$$={MULT};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression DIV expression {$$={DIV};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression MODULO expression {$$={MODULO};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression EQUAL expression {$$={EQUAL};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression LESSER expression {$$={LESSER};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   expression GREATER expression {$$={GREATER};$$.child_expressions.push_back($1);$$.child_expressions.push_back($3);}
|   LEFTPAR expression RIGHTPAR {$$={PARENTHESIS};}
|   IDENTIFIER {$$={IDENTIFIER};$$.string_value=$1;}

;


%%

namespace yy{
    void parser::error (const std::string& msg){
        std::cerr << "Parsing error: " << msg << std::endl;
    }
};

int main(int argc, char ** argv){
    if(argc >= 2){
        input_stream.open(argv[1]);
    }
    yy::parser parse;
    parse();
    

    return 0;
}


