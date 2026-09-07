/**
 * constants/jobStatuses.js
 *
 * All job status strings in one place.
 * Every status transition in the app references these constants —
 * never raw strings in components or hooks.
 * Must stay in sync with job_status_history records in Supabase.
 */

export const JOB_STATUS = {
  INQUIRY_RECEIVED:    'inquiry_received',
  ASSESSMENT_SCHEDULED:'assessment_scheduled',
  ASSESSMENT_COMPLETE: 'assessment_complete',
  QUOTE_IN_PROGRESS:   'quote_in_progress',
  QUOTE_SENT:          'quote_sent',
  QUOTE_APPROVED:      'quote_approved',
  QUOTE_DECLINED:      'quote_declined',
  JOB_SCHEDULED:       'job_scheduled',
  JOB_IN_PROGRESS:     'job_in_progress',
  JOB_COMPLETE:        'job_complete',
  INVOICE_SENT:        'invoice_sent',
  INVOICE_PAID:        'invoice_paid',
}

/**
 * Ordered list of statuses for display and progress tracking.
 * Represents the happy path through the job lifecycle.
 */
export const JOB_STATUS_ORDER = [
  JOB_STATUS.INQUIRY_RECEIVED,
  JOB_STATUS.ASSESSMENT_SCHEDULED,
  JOB_STATUS.ASSESSMENT_COMPLETE,
  JOB_STATUS.QUOTE_IN_PROGRESS,
  JOB_STATUS.QUOTE_SENT,
  JOB_STATUS.QUOTE_APPROVED,
  JOB_STATUS.JOB_SCHEDULED,
  JOB_STATUS.JOB_IN_PROGRESS,
  JOB_STATUS.JOB_COMPLETE,
  JOB_STATUS.INVOICE_SENT,
  JOB_STATUS.INVOICE_PAID,
]

/**
 * Human-readable labels for display in the UI.
 * Keyed by JOB_STATUS value.
 */
export const JOB_STATUS_LABEL = {
  [JOB_STATUS.INQUIRY_RECEIVED]:    'Inquiry Received',
  [JOB_STATUS.ASSESSMENT_SCHEDULED]:'Assessment Scheduled',
  [JOB_STATUS.ASSESSMENT_COMPLETE]: 'Assessment Complete',
  [JOB_STATUS.QUOTE_IN_PROGRESS]:   'Quote In Progress',
  [JOB_STATUS.QUOTE_SENT]:          'Quote Sent',
  [JOB_STATUS.QUOTE_APPROVED]:      'Quote Approved',
  [JOB_STATUS.QUOTE_DECLINED]:      'Quote Declined',
  [JOB_STATUS.JOB_SCHEDULED]:       'Job Scheduled',
  [JOB_STATUS.JOB_IN_PROGRESS]:     'Job In Progress',
  [JOB_STATUS.JOB_COMPLETE]:        'Job Complete',
  [JOB_STATUS.INVOICE_SENT]:        'Invoice Sent',
  [JOB_STATUS.INVOICE_PAID]:        'Invoice Paid',
}