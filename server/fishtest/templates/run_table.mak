<%page args="runs, pages=None, show_delete=False, header=None, count=None, toggle=None, alt=None, title=''"/>

<%namespace name="base" file="base.mak"/>

% if toggle is None:
    <script>
      document.title = '${username + " - " if username else ""}Finished Tests${title} - page ${page_idx+1} | Stockfish Testing';
    </script>
% endif

<%
  from fishtest.util import get_cookie
  if toggle:
    cookie_name = toggle+"_state"
%>

% if toggle:
<script>
  function toggle_${toggle}() {
    const button = document.getElementById("${toggle}-button");
    const div = document.getElementById("${toggle}");
    const active = button.textContent.trim() === "Hide";
    button.textContent = active ? "Show" : "Hide";
    document.cookie =
      "${cookie_name}" + "=" + button.textContent.trim() + ";max-age=${60 * 60 * 24 * 365 * 10};SameSite=Lax;";
  }
</script>
% endif


<h4>
% if toggle:
    <a id="${toggle}-button" class="btn btn-sm btn-light border" 
    data-bs-toggle="collapse" href="#${toggle}" role="button" aria-expanded="false"
    aria-controls="${toggle}" onclick="toggle_${toggle}()">
    ${'Hide' if get_cookie(request, cookie_name)=='Hide' else 'Show'}
    </a>
% endif
% if header is not None and count is not None:
  ${header} - ${count} tests
% elif header is not None:
  ${header}
% elif count is not None:
  ${count} tests
% endif
</h4>

<div
   id="${toggle}"
% if toggle:
   class="${'collapse show' if get_cookie(request, cookie_name)=='Hide' else 'collapse'}"
% endif
>

  <%include file="pagination.mak" args="pages=pages"/>

  <div class="table-responsive-lg">
    <table class="table table-striped table-sm run-table">
      <tbody>
        % for run in runs:
            <tr>
              % if show_delete:
                  <td style="width: 1%;" class="run-button run-deny">
                    <div class="dropdown">
                      <button type="submit" class="btn btn-danger btn-sm" data-bs-toggle="dropdown">
                        <i class="fas fa-trash-alt"></i>
                      </button>
                      <div class="dropdown-menu" role="menu">
                        <form action="/tests/delete" method="POST" style="display: inline;">
                          <input type="hidden" name="csrf_token" value="${request.session.get_csrf_token()}">
                          <input type="hidden" name="run-id" value="${run['_id']}">
                          <button type="submit" class="btn btn-danger btn-mini">Confirm</button>
                        </form>
                      </div>
                    </div>
                  </td>

              % endif

              <td style="width: 6%;" class="run-date">
                ${run['start_time'].strftime("%y-%m-%d")}
              </td>

              <td style="width: 2%;" class="run-user">
                <a href="/tests/user/${run['args'].get('username', '')}"
                   title="${run['args'].get('username', '')}">
                  ${run['args'].get('username', '')[:3]}
                </a>
              </td>

              <td style="width: 16%;" class="run-view">
                <a href="/tests/view/${run['_id']}">${run['args']['new_tag'][:23]}</a>
              </td>

              <td style="width: 2%;" class="run-diff">
                <a href="${h.diff_url(run)}" target="_blank" rel="noopener">diff</a>
              </td>

              <td style="width: 1%;" class="run-elo">
                <%include file="elo_results.mak" args="run=run" />
              </td>

              <td style="width: 11%;" class="run-live">
                % if 'sprt' in run['args']:
                    <a href="/tests/live_elo/${str(run['_id'])}" target="_blank">sprt</a>
                % else:
                  ${run['args']['num_games']}
                % endif
                @ ${run['args']['tc']} th ${str(run['args'].get('threads',1))}
                <br>
                ${('cores: '+str(run['cores'])) if not run['finished'] and 'cores' in run else ''}
              </td>

              <td class="run-info">
                ${run['args'].get('info', '')}
              </td>
            </tr>
        % endfor
        % if alt and count == 0:
          <tr>
            <td> ${alt} </td>
          </tr>
        % endif
      </tbody>
    </table>
  </div>

  <%include file="pagination.mak" args="pages=pages"/>
</div>
