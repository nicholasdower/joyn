use clap::Parser;
use std::io::{self, BufRead, Write};

const VERSION: &str = env!("CARGO_PKG_VERSION");

const HELP: &str = "\
usage: join [-d <delimiter>] [file ...]

Description

    Join lines, optionally using the specified delimeter.

Options

    -h, --help       Print help.
    -v, --version    Print version.\
";

#[derive(Parser)]
#[command(disable_help_flag = true)]
struct Cli {
    #[arg(short, long)]
    help: bool,

    #[arg(short, long)]
    version: bool,

    #[arg()]
    delimiter: Option<String>,
}

fn main() {
    match run() {
        Ok(_) => std::process::exit(0),
        Err(e) => {
            eprintln!("error: {e}");
            std::process::exit(1);
        }
    }
}

fn run() -> Result<(), String> {
    let args = Cli::try_parse().map_err(|e| format!("{}\n{HELP}", e.kind()))?;

    if args.help {
        println!("{HELP}");
        return Ok(());
    }

    if args.version {
        println!("join {VERSION}");
        return Ok(());
    }

    if atty::is(atty::Stream::Stdin) {
        return Err("nothing to quote".to_string());
    }

    let delimiter = match args.delimiter {
        Some(d) => convert_escape_sequences(&d),
        None => "".to_string(),
    };
    stream(&delimiter).map_err(|e| e.to_string())
}

fn stream(delimiter: &String) -> io::Result<()> {
    let delimiter = delimiter.as_bytes();

    let mut stdin = io::stdin().lock();
    let mut stdout = io::stdout();
    let mut newline = false;

    loop {
        let buffer = stdin.fill_buf()?;

        if buffer.is_empty() {
            break;
        }

        let buffer_len = buffer.len();
        for &byte in buffer {
            if newline {
                stdout.write_all(delimiter)?;
                newline = false;
            }
            if byte == b'\n' {
                newline = true;
            } else {
                stdout.write_all(&[byte])?;
            }
        }

        if newline {
            stdout.write_all(b"\n")?;
        }

        stdin.consume(buffer_len);
    }

    Ok(())
}

fn convert_escape_sequences(input: &str) -> String {
    let mut result = String::with_capacity(input.len());

    let mut chars = input.chars().peekable();
    while let Some(c) = chars.next() {
        if c == '\\' {
            match chars.peek() {
                Some(&'n') => {
                    result.push('\n');
                    chars.next();
                }
                Some(&'t') => {
                    result.push('\t');
                    chars.next();
                }
                Some(&'\\') => {
                    result.push('\\');
                    chars.next();
                }
                Some(&d) => {
                    result.push(d);
                    chars.next();
                }
                _ => result.push(c),
            }
        } else {
            result.push(c);
        }
    }

    result
}
