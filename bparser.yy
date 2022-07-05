%{
#include <iostream>
#include <string>
#include <fstream>

std::ifstream input_stream;

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

%left PLUS MINUS MULT DIV MODULO EQUAL GREATER LESSER
%right ASSIGN

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
    [a-zA-Z_]+  {putback(); return parser::make_IDENTIFIER(input.substr(0,len));}
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



*/
}

}
}

%%

library:
    %empty
|   library function

function:
    IDENTIFIER statement {std::cout << "function" << std::endl;}

statement:
    compound_statement RIGHTCURLY {}
|   expression SEMICOLON {}
|   IF LEFTPAR expression RIGHTPAR statement {}
|   WHILE LEFTPAR expression RIGHTPAR statement {}
|   RETURN SEMICOLON {}
|   RETURN expression SEMICOLON {}
|   VAR IDENTIFIER SEMICOLON {}
|   SEMICOLON {}
;

compound_statement:
    LEFTCURLY
|   compound_statement statement
;

expression:
    INTEGER
|   IDENTIFIER
|   expression PLUS expression
|   expression MINUS expression
|   expression MULT expression
|   expression DIV expression
|   expression MODULO expression
|   expression EQUAL expression
|   expression ASSIGN expression
|   expression LESSER expression
|   expression GREATER expression
|   LEFTPAR expression RIGHTPAR

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


