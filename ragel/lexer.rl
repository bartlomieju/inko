%%machine aeon_lexer;

%% write data;

pub fn lex<F: FnMut(Token)>(input: &str, mut callback: F) -> Result<(), ()> {
    let data = input.as_bytes();

    let mut line   = 1;
    let mut column = 1;

    let mut ts  = 0;
    let mut te  = 0;
    let mut act = 0;
    let eof     = input.len();

    let mut p       = 0;
    let mut pe      = input.len();
    let mut cs: i32 = 0;

    %% write init;
    %% write exec;

    Ok(())
}

%%{
    action advance_line {
        line += 1;
        column = 1;
    }

    action advance_column {
        column += 1;
    }

    newline = ('\r\n' | '\n') @advance_line;

    unicode    = any - ascii;
    identifier = ([a-z_] | unicode) ([a-zA-Z0-9_] | unicode)*;
    constant   = upper identifier?;
    ivar       = '@' identifier;

    integer = digit+ ('_' digit+)*;
    float   = integer '.' integer;

    squote  = "'";
    dquote  = '"';
    sstring = squote ( [^'\\] | /\\./ )* squote;
    dstring = dquote ( [^"\\] | /\\./ )* dquote;

    comment   = '#' ^newline+;
    docstring = '/*' any* :>> '*/';

    colon  = ':';
    dcolon = colon colon;
    lparen = '(';
    rparen = ')';
    lbrack = '[';
    rbrack = ']';
    lcurly = '{';
    rcurly = '}';
    eq     = '=';
    comma  = ',';
    dot    = '.';
    arrow  = '->';
    append = '+=';
    lt     = '<';
    gt     = '>';
    pipe   = '|';

    operator = '+' | '-' | '/' | '%' | '*';

    main := |*
        comment | newline;

        'trait'    => { emit!(Trait, data, ts, te, line, column, 0, callback); };
        'class'    => { emit!(Class, data, ts, te, line, column, 0, callback); };
        'def'      => { emit!(Def, data, ts, te, line, column, 0, callback); };
        'enum'     => { emit!(Enum, data, ts, te, line, column, 0, callback); };
        'use'      => { emit!(Use, data, ts, te, line, column, 0, callback); };
        'import'   => { emit!(Import, data, ts, te, line, column, 0, callback); };
        'as'       => { emit!(As, data, ts, te, line, column, 0, callback); };
        'let'      => { emit!(Let, data, ts, te, line, column, 0, callback); };
        'mut'      => { emit!(Mutable, data, ts, te, line, column, 0, callback); };
        'return'   => { emit!(Return, data, ts, te, line, column, 0, callback); };
        'super'    => { emit!(Super, data, ts, te, line, column, 0, callback); };
        'break'    => { emit!(Break, data, ts, te, line, column, 0, callback); };
        'continue' => { emit!(Continue, data, ts, te, line, column, 0, callback); };
        'pub'      => { emit!(Public, data, ts, te, line, column, 0, callback); };
        'dyn'      => { emit!(Dynamic, data, ts, te, line, column, 0, callback); };

        docstring => {
            emit!(Docstring, data, ts + 2, te - 2, line, column, 4, callback);
        };

        integer => { emit!(Int, data, ts, te, line, column, 0, callback); };
        float   => { emit!(Float, data, ts, te, line, column, 0, callback); };

        dstring => {
            emit_string!(data, ts, te, line, column, "\\\"", "\"", callback);
        };

        sstring => {
            emit_string!(data, ts, te, line, column, "\\'", "'", callback);
        };

        ivar => {
            emit!(InstanceVariable, data, ts + 1, te, line, column, 1, callback);
        };

        identifier => {
            emit!(Identifier, data, ts, te, line, column, 0, callback);
        };

        constant => {
            emit!(Constant, data, ts, te, line, column, 0, callback);
        };

        pipe     => { emit!(Pipe, data, ts, te, line, column, 0, callback); };
        dcolon   => { emit!(ColonColon, data, ts, te, line, column, 0, callback); };
        arrow    => { emit!(Arrow, data, ts, te, line, column, 0, callback); };
        colon    => { emit!(Colon, data, ts, te, line, column, 0, callback); };
        lparen   => { emit!(ParenOpen, data, ts, te, line, column, 0, callback); };
        rparen   => { emit!(ParenClose, data, ts, te, line, column, 0, callback); };
        lbrack   => { emit!(BrackOpen, data, ts, te, line, column, 0, callback); };
        rbrack   => { emit!(BrackClose, data, ts, te, line, column, 0, callback); };
        lcurly   => { emit!(CurlyOpen, data, ts, te, line, column, 0, callback); };
        rcurly   => { emit!(CurlyClose, data, ts, te, line, column, 0, callback); };
        eq       => { emit!(Equal, data, ts, te, line, column, 0, callback); };
        comma    => { emit!(Comma, data, ts, te, line, column, 0, callback); };
        dot      => { emit!(Dot, data, ts, te, line, column, 0, callback); };
        append   => { emit!(Append, data, ts, te, line, column, 0, callback); };
        operator => { emit!(Operator, data, ts, te, line, column, 0, callback); };
        lt       => { emit!(Lower, data, ts, te, line, column, 0, callback); };
        gt       => { emit!(Greater, data, ts, te, line, column, 0, callback); };

        any => advance_column;
    *|;
}%%

// vim: set ft=ragel:
