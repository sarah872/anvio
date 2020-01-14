#! /usr/bin/env python
import anvio
import anvio.errors as errors
import anvio.terminal as terminal

from colored import fore, style, back

class AnvioSnakeMakeLogger(object):
    run = terminal.Run()
    progress = terminal.Progress()
    printreason = False

    submitted_job_info_color_keys = 'yellow'
    submitted_job_info_color = 'yellow'
    finished_job_info_color_keys = 'green'
    finished_job_info_color = 'green'

    first_log = True
    total_jobs = 0
    jobs_done = 0

    all_job_info = {}

    @classmethod
    def update_active_and_completed_job_msg(cls):
        completed_jobs = {k: v for k, v in cls.all_job_info.items() if v['complete']}
        active_jobs = {k: v for k, v in cls.all_job_info.items() if not v['complete']}

        message = '%d of %d steps done; %d active job IDs: %s' % \
                      (len(completed_jobs), cls.total_jobs, len(active_jobs), ','.join([str(job) for job in active_jobs]))

        cls.progress.update(message)


    @classmethod
    def anvio_logger(cls, msg):
        '''The anvi'o custom snakemake logger

        Parameters
        ==========
        msg : dict
            msg has the following entries depending on what level it contains:
                :level:
                    the log level ('info', 'error', 'debug', 'progress', 'job_info')
                :level='info', 'error' or 'debug':
                    :msg:
                        the log message
                :level='progress':
                    :done:
                        number of already executed jobs
                    :total:
                        number of total jobs
                :level='job_info':
                    :input:
                        list of input files of a job
                    :output:
                        list of output files of a job
                    :log:
                        path to log file of a job
                    :local:
                        whether a job is executed locally (i.e. ignoring cluster)
                    :msg:
                        the job message
                    :reason:
                        the job reason
                    :priority:
                        the job priority
                    :threads:
                        the threads of the job

        Notes
        =====
        - This is only available for snakemake >= 5.9.1
        '''

        if cls.first_log:
            cls.progress.new('anvi-run-workflow')
            cls.progress.update('Initializing')
            cls.first_log = False

        level = msg['level']
        print(level)

        def timestamp():
            cls.progress.clear()
            print(fore.GREEN + '\n[' + terminal.get_date() + ']' + style.RESET)
            cls.progress.update(cls.progress.msg)

        format_value = lambda value, omit=None, valueformat=str: valueformat(value) if value != omit else None
        format_wildcards = lambda wildcards: ', '.join(['%s=%s' % (k, v) for k, v in wildcards.items()])
        format_resources = lambda resources: ', '.join(['%s=%s' % (k, v) for k, v in resources.items() if not k.startswith('_')])

        if level == 'job_info':
            if msg['msg'] is not None:
                cls.run.info('Job %s' % msg['jobid'], msg['msg'], nl_before=0, nl_after=0, progress=cls.progress)
                if cls.printreason:
                    cls.run.info('Reason', msg['reason'], nl_before=0, nl_after=0, progress=cls.progress)
            else:
                cls.all_job_info[msg['jobid']] = msg
                cls.all_job_info[msg['jobid']]['complete'] = False
                cls.all_job_info[msg['jobid']]['timer'] = terminal.Timer()
                cls.update_active_and_completed_job_msg()

                cls.run.warning('', header='[SUBMITTING Job %s] %srule %s' % \
                                    (msg['jobid'],
                                     'local' if msg['local'] else '',
                                     msg['name']),
                                lc='yellow', nl_before=0, progress=cls.progress)

                cls.run.info('timestamp', terminal.get_date(), progress=cls.progress, lc=cls.submitted_job_info_color_keys, mc=cls.submitted_job_info_color)

                for item in ['input', 'output', 'log']:
                    value = format_value(msg[item], omit=[], valueformat=', '.join)
                    if value is not None:
                        cls.run.info(item, value, progress=cls.progress, lc=cls.submitted_job_info_color_keys, mc=cls.submitted_job_info_color)

                for item in ['jobid', 'benchmark'] + ([] if not cls.printreason else ['reason']):
                    value = format_value(msg[item], omit=None)
                    if value is not None:
                        cls.run.info(item, value, progress=cls.progress, lc=cls.submitted_job_info_color_keys, mc=cls.submitted_job_info_color)

                wildcards = format_wildcards(msg['wildcards'])
                if wildcards:
                    cls.run.info('wildcards', wildcards, progress=cls.progress, lc=cls.submitted_job_info_color_keys, mc=cls.submitted_job_info_color)

                for item, omit in zip('priority threads'.split(), [0, 1]):
                    value = format_value(msg[item], omit=omit)
                    if value is not None:
                        cls.run.info(item, value, progress=cls.progress, lc=cls.submitted_job_info_color_keys, mc=cls.submitted_job_info_color)

                resources = format_resources(msg['resources'])
                if resources:
                    cls.run.info('resources', resources, progress=cls.progress, lc=cls.submitted_job_info_color_keys, mc=cls.submitted_job_info_color)

        elif level == 'group_info':
            try:
                if anvio.DEBUG:
                    print('never tested:')
                timestamp()
                cls.run.info_single('group job %s (jobs in lexicogr. order):' % str(msg['groupid']), progress=cls.progress)
            except Exception as e:
                print(e)
                cls.run.warning("AnvioSnakeMakeLogger :: \'group_info\' log message has failed because it's never been tested. \
                                 This is like finding a rare Pokémon. Please report the above error messages to the developers.",
                                 header = 'DEVELOPER NOTE', progress=cls.progress, nl_after=0)

        elif level == 'job_error':
            timestamp()
            cls.run.warning('An error in rule %s (job ID %s) has occurred.' % (msg['name'].strip(), msg['jobid']), 
                            header = 'JobError', progress=cls.progress, nl_after=0)
            if msg['output']:
                cls.run.info('output', ', '.join(msg['output']), lc='red', mc='red', progress=cls.progress)
            if msg['log']:
                cls.run.info('log', ', '.join(msg['log']), lc='red', mc='red', progress=cls.progress)
            if msg['conda_env']:
                cls.run.info('conda-env', msg['conda_env'], lc='red', mc='red', progress=cls.progress)
            for k, v in msg['aux'].items():
                cls.run.info(k, v, progress=cls.progress, lc='red', mc='red')

        elif level == 'group_error':
            try:
                if anvio.DEBUG:
                    print('never tested:')
                timestamp()
                cls.run.warning('A group error in job ID %s has occurred.' % (msg['jobid']), 
                                header = 'GroupError', progress=cls.progress, nl_after=0)
            except Exception as e:
                print(e)
                cls.run.warning("AnvioSnakeMakeLogger :: \'group_error\' log message has failed because it's never been tested. \
                                 This is like finding a rare Pokémon. Please report the above error messages to the developers.",
                                 header = 'DEVELOPER NOTE', progress=cls.progress, nl_after=0)

        else:
            if level == 'info':
                cls.run.info_single(msg['msg'], progress=cls.progress)
            if level == 'warning':
                cls.run.warning(msg['msg'], header='warning', progress=cls.progress)
            elif level == 'error':
                cls.run.warning(msg['msg'], header='SnakeMakeError', raw=True, progress=cls.progress)
                if 'Exiting because a job execution failed.' in msg['msg']:
                    cls.progress.end()
                    cls.progress = None
            elif level == 'debug':
                if anvio.DEBUG:
                    cls.run.warning(msg['msg'], header='debug', raw=True, progress=cls.progress)
            elif level == 'resources_info':
                cls.run.info_single(msg['msg'], progress=cls.progress)
            elif level == 'run_info':
                # we needed the total number of items from this string (I know) to start proper
                # progress object (I know)
                cls.total_jobs = int(msg['msg'].strip().split()[-1])
                cls.progress.end()
                cls.progress.new('anvi-run-workflow', progress_total_items=cls.total_jobs)
                cls.progress.update('%d of %d steps done' % (cls.jobs_done, cls.total_jobs))

                cls.progress.clear()
                print(fore.CYAN + '\n' + msg['msg'] + style.RESET)
                cls.progress.update(cls.progress.msg)
            elif level == 'progress':
                cls.total_jobs = msg['total']
                cls.jobs_done = msg['done']
                cls.progress.increment()
                cls.update_active_and_completed_job_msg()
            elif level == 'shellcmd':
                cls.run.info('shell command', errors.remove_spaces(msg['msg'].strip()), progress=cls.progress, lc=cls.submitted_job_info_color_keys, mc='cyan')
            elif level == 'job_finished':
                print('hi')
                cls.all_job_info[msg['jobid']]['complete'] = True
                cls.all_job_info[msg['jobid']]['elapsed time'] = cls.all_job_info[msg['jobid']]['timer'].time_elapsed()
                cls.run.warning('', header='[FINISHED Job %s] %srule %s' % \
                                    (msg['jobid'],
                                     'local' if cls.all_job_info[msg['jobid']]['local'] else '',
                                     cls.all_job_info[msg['jobid']]['name']),
                                lc='green', nl_before=0, progress=cls.progress)

                cls.run.info('timestamp', terminal.get_date(), progress=cls.progress, lc=cls.finished_job_info_color_keys, mc=cls.finished_job_info_color)
                cls.run.info('time taken', cls.all_job_info[msg['jobid']]['elapsed time'], progress=cls.progress, lc=cls.finished_job_info_color_keys, mc=cls.finished_job_info_color)
                for item in ['output', 'log']:
                    value = format_value(cls.all_job_info[msg['jobid']][item], omit=[], valueformat=', '.join)
                    if value is not None:
                        cls.run.info(item, value, progress=cls.progress, lc=cls.finished_job_info_color_keys, mc=cls.finished_job_info_color)

            elif level == 'rule_info':
                try:
                    if anvio.DEBUG:
                        print('never tested:')
                    cls.run.info_single(msg['name'], progress=cls.progress)
                    if msg['docstring']:
                        cls.run.info('docstring', msg['docstring'], progress=cls.progress)
                except Exception as e:
                    print(e)
                    cls.run.warning("AnvioSnakeMakeLogger :: \'rule_info\' log message has failed because it's never been tested. \
                                     This is like finding a rare Pokémon. Please report the above error messages to the developers.",
                                     header = 'DEVELOPER NOTE', progress=cls.progress, nl_after=0)
            elif level == 'd3dag':
                try:
                    if anvio.DEBUG:
                        print('never tested:')
                    print('never tested')
                    print(fore.YELLOW + json.dumps({'nodes': msg['nodes'], 'links': msg['edges']}) + style.RESET)
                except Exception as e:
                    print(e)
                    cls.run.warning("AnvioSnakeMakeLogger :: \'d3dag\' log message has failed because it's never been tested. \
                                     This is like finding a rare Pokémon. Please report the above error messages to the developers.",
                                     header = 'DEVELOPER NOTE', progress=cls.progress, nl_after=0)


def log_handler(msg):
    AnvioSnakeMakeLogger.anvio_logger(msg)
