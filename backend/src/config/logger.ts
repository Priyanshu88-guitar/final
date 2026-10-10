import { env } from './env.js';
import { sanitizeData } from '../utils/sanitizer.js';

type LogLevel = 'debug' | 'info' | 'warn' | 'error';

const LOG_LEVELS: Record<LogLevel, number> = {
  debug: 0,
  info: 1,
  warn: 2,
  error: 3,
};

class Logger {
  private currentLevel: number;

  constructor() {
    this.currentLevel = LOG_LEVELS[env.LOG_LEVEL as LogLevel] ?? 1;
  }

  private shouldLog(level: LogLevel): boolean {
    return LOG_LEVELS[level] >= this.currentLevel;
  }

  private formatMessage(level: LogLevel, message: string, meta?: unknown): string {
    const timestamp = new Date().toISOString();
    const sanitizedMeta = meta ? sanitizeData(meta) : undefined;

    let formatted = `[${timestamp}] [${level.toUpperCase()}] ${message}`;
    if (sanitizedMeta !== undefined) {
      formatted += ` ${JSON.stringify(sanitizedMeta)}`;
    }
    return formatted;
  }

  debug(message: string, meta?: unknown): void {
    if (this.shouldLog('debug')) {
      console.debug(this.formatMessage('debug', message, meta));
    }
  }

  info(message: string, meta?: unknown): void {
    if (this.shouldLog('info')) {
      console.log(this.formatMessage('info', message, meta));
    }
  }

  warn(message: string, meta?: unknown): void {
    if (this.shouldLog('warn')) {
      console.warn(this.formatMessage('warn', message, meta));
    }
  }

  error(message: string, meta?: unknown): void {
    if (this.shouldLog('error')) {
      console.error(this.formatMessage('error', message, meta));
    }
  }
}

export const logger = new Logger();
