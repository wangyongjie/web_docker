'use strict';

const Controller = require('egg').Controller;

class HomeController extends Controller {
  getCommand(project) {
    const projectCommand = {
      kiwiwebsite: [ 'pc', 'mobile' ],
      kkpoker_club: [ 'mobile' ],
      'operation-activity': [],
    };

    if (projectCommand[project]) {
      if (projectCommand[project].length === 1) {
        return `cd /deploy/${project} && git checkout . && git fetch --all && cd ${projectCommand[project][0]} && bash ./build.sh`;
      } else if (projectCommand[project].length > 1) {
        // 暂时限制配两层
        return `cd /deploy/${project} && git checkout . && git git fetch --all && cd ${projectCommand[project][0]} && bash ./build.sh && cd ../${projectCommand[project][1]} && bash ./build.sh`;
      }
      return `cd /deploy/${project} && git checkout . && git git fetch --all && bash ./build.sh`;

    }

    // 不配置，默认为一层
    return `cd /deploy/${project} && git checkout . && git pull && bash ./build.sh`;
  }

  async index() {
    const { ctx } = this;
    const project = ctx.params.project;
    const { exec } = require('child_process');
    ctx.logger.info('start update', ctx.request.body);
    const logTag = project + Date.now();
    exec(this.getCommand(project), (err, stdout, stderr) => {
      if (err) {
        // eslint-disable-next-line no-useless-concat
        const temp = '\n' + 'start:' + logTag + '\n' + err + '\n' + 'end:' + logTag + '\n';
        ctx.logger.error(temp);
        this.noticeRobot(ctx, project, 'Error', err.toString(), logTag);
        return;
      }
      // eslint-disable-next-line no-useless-concat
      const temp = '\n' + 'start:' + logTag + '\n' + stdout + '\n' + 'end:' + logTag + '\n';
      ctx.logger.info('update log', temp, stderr);
      this.noticeRobot(ctx, project, 'Updated', stdout.replace(/>/g, ''), logTag);
    });

    ctx.body = 'completed';
  }

  noticeRobot(ctx, project, type, content, logTag) {
    const d = new Date();
    const now = d.getFullYear() + '-' + (d.getMonth() + 1) + '-' + d.getDate() + ' ' + d.getHours() + ':' + (d.getMinutes() + 1) + ':' + d.getSeconds();
    content = content.substring(0, 100) + '...';
    ctx.curl('https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=01ea6de7-db89-4af7-9424-ba9feb0544b0', {
      method: 'POST',
      contentType: 'json',
      data: {
        msgtype: 'markdown',
        markdown: {
          content: `<font color=\"warning\">${project}</font> 项目 <font color=\"warning\">dev</font> 环境，触发更新提示。\n>触发时间: ${now}\n>触发类型: ${type}\n>详细日志: \n\n${content}\n[More](http://10.100.1.199:7001/getlog/${logTag})`,
        },
      },
      dataType: 'json',
    });
  }

  async getLog() {
    const { ctx } = this;
    const tag = ctx.params.tag;
    const fs = require('fs');
    const readline = require('readline');
    const fileStream = fs.createReadStream('/deploy/node_server/log/node_server-web.log');
    const rl = readline.createInterface({
      input: fileStream,
      crlfDelay: Infinity,
    });

    let result = '';
    let readtag = false;
    let start = '';

    for await (const line of rl) {
      if (('start:' + tag) === line) {
        readtag = true;
        result += start + '\n';
      }
      if (('end:' + tag) === line) {
        readtag = false;
      }
      if (readtag && ('start:' + tag) !== line) {
        result += line + '\n';
      }
      start = line;
    }

    ctx.body = result;
  }
}

module.exports = HomeController;
