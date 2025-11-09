%{
/* * CoreLang Scanner
 * This section has C code.
 */
#include <stdio.h>
#include <string.h>

/* Global variables */
FILE *tokens_file;
FILE *errors_file;

int line_count = 1;
int keyword_count = 0;
int identifier_count = 0;
int operator_count = 0;
int punctuation_count = 0;
int number_count = 0;
int error_count = 0;


void log_token(const char* type, const char* text) {
    if (tokens_file != NULL) {
        fprintf(tokens_file, "Line %d: %s -> %s\n", line_count, type, text);
    }
}


void log_error(const char* text) {
    if (errors_file != NULL) {
        fprintf(errors_file, "Line %d: ERROR -> Invalid token '%s'\n", line_count, text);
        error_count++;
    }
}

%}

/* Flex options */
%option noyywrap

/* * Define token rules
 * The order is important!
 * Keywords must come before Identifiers.
 * Floats must come before Integers.
 */
%%

"begin_main"    { log_token("KEYWORD", yytext); keyword_count++; }
"end_main"      { log_token("KEYWORD", yytext); keyword_count++; }
"integer"       { log_token("KEYWORD", yytext); keyword_count++; }
"real"          { log_token("KEYWORD", yytext); keyword_count++; }
"text"          { log_token("KEYWORD", yytext); keyword_count++; }
"print"         { log_token("KEYWORD", yytext); keyword_count++; }
"read"          { log_token("KEYWORD", yytext); keyword_count++; }
"if_cond"       { log_token("KEYWORD", yytext); keyword_count++; }
"else_cond"     { log_token("KEYWORD", yytext); keyword_count++; }
"repeat_while"  { log_token("KEYWORD", yytext); keyword_count++; }
"proc"          { log_token("KEYWORD", yytext); keyword_count++; }
"return_val"    { log_token("KEYWORD", yytext); keyword_count++; }
"true"          { log_token("KEYWORD", yytext); keyword_count++; }
"false"         { log_token("KEYWORD", yytext); keyword_count++; }
"constant"      { log_token("KEYWORD", yytext); keyword_count++; }

\d+\.\d+        { log_token("FLOAT", yytext); number_count++; }
\d+             { log_token("INTEGER", yytext); number_count++; }

[a-zA-Z_][a-zA-Z0-9_]* { log_token("IDENTIFIER", yytext); identifier_count++; }

":="            { log_token("OPERATOR", yytext); operator_count++; }
"+"             { log_token("OPERATOR", yytext); operator_count++; }
"*"             { log_token("OPERATOR", yytext); operator_count++; }
"-"             { log_token("OPERATOR", yytext); operator_count++; }
"/"             { log_token("OPERATOR", yytext); operator_count++; }
">"             { log_token("OPERATOR", yytext); operator_count++; }
"<"             { log_token("OPERATOR", yytext); operator_count++; }
"=="            { log_token("OPERATOR", yytext); operator_count++; }

";"             { log_token("PJ_PUNCTUATION", yytext); punctuation_count++; }
"("             { log_token("PUNCTUATION", yytext); punctuation_count++; }
")"             { log_token("PUNCTUATION", yytext); punctuation_count++; }


[ \t]+          /* Ignore whitespace */
\n              { line_count++; } /* Count new lines */

.               { log_error(yytext); } /* Catch all other invalid characters */

%%


int main(int argc, char *argv[]) {
    
    /* Check if user gave an input file */
    if (argc < 2) {
        printf("Usage: ./scanner <input_file>\n");
        return 1;
    }

    /* Open input file to read */
    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        printf("Error: Could not open input file %s\n", argv[1]);
        return 1;
    }

    /* Open output files to write */
    tokens_file = fopen("tokens.txt", "w");
    if (tokens_file == NULL) {
        printf("Error: Could not open tokens.txt\n");
        return 1;
    }

    errors_file = fopen("error_log.txt", "w");
    if (errors_file == NULL) {
        printf("Error: Could not open error_log.txt\n");
        fclose(tokens_file);
        return 1;
    }

    printf("Scanning file: %s\n", argv[1]);

    /* Run the scanner */
    yylex();

    /* Close files */
    fclose(yyin);
    fclose(tokens_file);
    fclose(errors_file);

    /* Print summary */
    printf("\n--- Scan Complete ---\n");
    printf("Total Keywords:     %d\n", keyword_count);
    printf("Total Identifiers:  %d\n", identifier_count);
    printf("Total Numbers:      %d\n", number_count);
    printf("Total Operators:    %d\n", operator_count);
    printf("Total Punctuations: %d\n", punctuation_count);
    
    if (error_count > 0) {
        printf("\nFound %d error(s). Check error_log.txt\n", error_count);
    } else {
        printf("\nNo errors found.\n");
        /* Delete empty error file if no errors */
        remove("error_log.txt");
    }

    printf("Token output written to tokens.txt\n");

    return 0;
}