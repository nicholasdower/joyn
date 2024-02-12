use clap::Parser;
use std::{fs::File, io::{self, BufRead, Write}};

const VERSION: &str = env!("CARGO_PKG_VERSION");

const HELP: &str = "\
usage: joyn [-d <delimiter>] [file ...]

Join lines

Options

    -d, --delimiter  The line delimiter.
    -h, --help       Print help.
    -v, --version    Print version.

Installation

    Install:

        brew install nicholasdower/tap/joyn

    Uninstall:

        brew uninstall joyn
";

#[derive(Parser)]
#[command(disable_help_flag = true)]
struct Cli {
    #[arg(short, long)]
    help: bool,

    #[arg(short, long)]
    version: bool,

    #[arg(short, long)]
    delimiter: Option<String>,

    #[arg(name = "file")]
    files: Vec<String>,
}

fn main() {
    match run() {
        Ok(_) => std::process::exit(0),
        Err(e) => {
            eprintln!("error: {e}");
            std::process::exit(1);
        },
    }
}

fn run() -> Result<(), String> {
    let args = Cli::try_parse().map_err(|e| format!("{}\n{HELP}", e.kind()))?;

    if args.help {
        println!("{HELP}");
        Ok(())
    } else if args.version {
        println!("joyn {VERSION}");
        Ok(())
    } else {
        let delimiter = convert_escape_sequences(&args.delimiter.unwrap_or("".to_string()));
        stream_all(args.files, delimiter.as_bytes())
    }
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

fn stream_all(files: Vec<String>, delimiter_bytes: &[u8]) -> Result<(), String> {
    let mut newline = false;
    if !files.is_empty() {
        files.iter().enumerate().try_for_each(|(i, file_path)| {
            match File::open(file_path) {
                Ok(file) => {
                    if i > 0 {
                        io::stdout().write_all(delimiter_bytes).map_err(|e| format!("{e}"))?;
                    }
                    newline = stream_one(io::BufReader::new(file), delimiter_bytes)?;
                    Ok(())
                },
                Err(e) => Err(format!("{e}")),
            }
        })?;
    } else if atty::is(atty::Stream::Stdin) {
        return Err("nothing to join".to_string());
    } else {
        newline = stream_one(io::stdin().lock(), delimiter_bytes)?;
    }

    if newline {
        io::stdout().write_all("\n".as_bytes()).map_err(|e| format!("{e}"))?;
    }
    Ok(())
}

fn stream_one<R: BufRead>(mut handle: R, delimiter: &[u8]) -> Result<bool, String> {
    let mut stdout = io::stdout();
    let mut newline = false;

    loop {
        let buffer = match handle.fill_buf() {
            Ok(buf) => buf,
            Err(e) => return Err(format!("{e}"))
        };

        if buffer.is_empty() {
            break;
        }

        let buffer_len = buffer.len();
        for &byte in buffer {
            if newline {
                stdout.write_all(delimiter).map_err(|e| format!("{e}"))?;
                newline = false;
            }
            if byte == b'\n' {
                newline = true;
            } else {
                stdout.write_all(&[byte]).map_err(|e| format!("{e}"))?;
            }
        }

        handle.consume(buffer_len);
    }

    Ok(newline)
}
